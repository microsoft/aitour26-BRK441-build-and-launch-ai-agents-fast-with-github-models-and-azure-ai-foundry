# http://localhost:8000

from fastapi import FastAPI, Request, WebSocket, WebSocketDisconnect, UploadFile, File
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
import uvicorn
import json
import asyncio
from typing import List, Dict, Optional
import logging
import base64
import os
from contextlib import AsyncExitStack
import uuid
from pathlib import Path

# MCP imports
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client
from mcp.client.sse import sse_client

# Azure AI imports
from azure.ai.inference import ChatCompletionsClient
from azure.ai.inference.models import AssistantMessage, SystemMessage, UserMessage, ToolMessage
from azure.ai.inference.models import ImageContentItem, ImageUrl, TextContentItem
from azure.core.credentials import AzureKeyCredential


from dotenv import load_dotenv

load_dotenv()  # Loads variables from .env into os.environ

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create uploads directory if it doesn't exist
UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(exist_ok=True)

def encodeImage(path, mime_type):
    """Encode image file to base64 for use with AI models"""
    with open(path, "rb") as image:
        encoded = base64.b64encode(image.read())
    return f"data:{mime_type};base64,{encoded.decode()}"

def get_image_mime_type(filename: str) -> str:
    """Get MIME type based on file extension"""
    extension = filename.lower().split('.')[-1]
    mime_types = {
        'jpg': 'image/jpeg',
        'jpeg': 'image/jpeg',
        'png': 'image/png',
        'gif': 'image/gif',
        'webp': 'image/webp',
        'bmp': 'image/bmp'
    }
    return mime_types.get(extension, 'image/jpeg')

class MCPClient:
    """MCP Client for connecting to Model Context Protocol servers"""
    def __init__(self):
        # Initialize session and client objects
        self._servers = {}
        self._tool_to_server_map = {}
        self.exit_stack = AsyncExitStack()
        # To authenticate with the model you will need to generate a personal access token (PAT) in your GitHub settings.
        # Create your PAT token by following instructions here: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens
        self.azureai = ChatCompletionsClient(
            endpoint = AzureKeyCredential(os.environ["AZURE_AI_ENDPOINT"]),
            credential = AzureKeyCredential(os.environ["AZURE_AI_API_KEY"]),
            api_version = "2025-01-01-preview",
        )

    async def connect_stdio_server(self, server_id: str, command: str, args: list[str], env: Dict[str, str]):
        """Connect to an MCP server using STDIO transport
        
        Args:
            server_id: Unique identifier for this server connection
            command: Command to run the MCP server
            args: Arguments for the command
            env: Optional environment variables
        """
        server_params = StdioServerParameters(
            command=command,
            args=args,
            env=env
        )
        
        stdio_transport = await self.exit_stack.enter_async_context(stdio_client(server_params))
        stdio, write = stdio_transport
        session = await self.exit_stack.enter_async_context(ClientSession(stdio, write))
        await session.initialize()
        
        # Register the server
        await self._register_server(server_id, session)
    
    async def connect_sse_server(self, server_id: str, url: str, headers: Dict[str, str]):
        """Connect to an MCP server using SSE transport
        
        Args:
            server_id: Unique identifier for this server connection
            url: URL of the SSE server
            headers: Optional HTTP headers
        """
        sse_context = await self.exit_stack.enter_async_context(sse_client(url=url, headers=headers))
        read, write = sse_context
        session = await self.exit_stack.enter_async_context(ClientSession(read, write))
        await session.initialize()
        
        # Register the server
        await self._register_server(server_id, session)
    
    async def _register_server(self, server_id: str, session: ClientSession):
        """Register a server and its tools in the client
        
        Args:
            server_id: Unique identifier for this server
            session: Connected ClientSession
        """
        # List available tools
        response = await session.list_tools()
        tools = response.tools
        
        # Store server connection info
        self._servers[server_id] = {
            "session": session,
            "tools": tools
        }
        
        # Update tool-to-server mapping
        for tool in tools:
            self._tool_to_server_map[tool.name] = server_id
            
        print(f"\nConnected to server '{server_id}' with tools:", [tool.name for tool in tools])

    async def chatWithTools(self, messages: list[any]) -> str:
        """Chat with model and using tools
        Args:
            messages: Messages to send to the model
        """
        if not self._servers:
            raise ValueError("No MCP servers connected. Connect to at least one server first.")

        # Collect tools from all connected servers
        available_tools = []
        for server_id, server_info in self._servers.items():
            for tool in server_info["tools"]:
                available_tools.append({ 
                    "type": "function",
                    "function": {
                        "name": tool.name,
                        "description": tool.description,
                        "parameters": tool.inputSchema
                    },
                })

        while True:

            # Call model
            response = self.azureai.complete(
                messages = messages,
                model = "gpt-4o",
                tools=available_tools,
                max_tokens = 4096,
            )
            hasToolCall = False

            if response.choices[0].message.tool_calls:
                for tool in response.choices[0].message.tool_calls:
                    hasToolCall = True
                    tool_name = tool.function.name
                    tool_args = json.loads(tool.function.arguments)
                    messages.append(
                        AssistantMessage(
                            tool_calls = [{
                                "id": tool.id,
                                "type": "function",
                                "function": {
                                    "name": tool.function.name,
                                    "arguments": tool.function.arguments,
                                }
                            }]
                        )
                    )
                
                
                    # Find the appropriate server for this tool
                    if tool_name in self._tool_to_server_map:
                        server_id = self._tool_to_server_map[tool_name]
                        server_session = self._servers[server_id]["session"]
                        
                        # Execute tool call on the appropriate server
                        result = await server_session.call_tool(tool_name, tool_args)
                        print(f"[Server '{server_id}' call tool '{tool_name}' with args {tool_args}]: {result.content}")

                        messages.append(
                            ToolMessage(
                                tool_call_id = tool.id,
                                content = str(result.content)
                            )
                        )
            else:
                messages.append(
                    AssistantMessage(
                        content = response.choices[0].message.content
                    )
                )
                print(f"[Model Response]: {response.choices[0].message.content}")
        
            if not hasToolCall:
                break
    
    async def cleanup(self):
        """Clean up resources"""
        await self.exit_stack.aclose()
        await asyncio.sleep(1)

app = FastAPI(title="AI Agent Chat Demo", version="1.0.0")

# Mount static files and templates
app.mount("/static", StaticFiles(directory="static"), name="static")
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")
templates = Jinja2Templates(directory="templates")

# Global MCP client instance
mcp_client = None

# System message for Cora AI assistant
CORA_SYSTEM_MESSAGE = SystemMessage(content = "You are Cora, an intelligent and friendly AI assistant for Zava, a home improvement brand. You help customers with their DIY projects by understanding their needs and recommending the most suitable products from Zava's catalog.\n\nYour role is to:\n- Engage with the customer in natural conversation to understand their DIY goals.\n- Ask thoughtful questions to gather relevant project details.\n- Be brief in your responses.\n- Provide the best solution for the customer's problem and only recommend a relevant product within Zava's product catalog.\n- Search Zava's product database to identify 1 product by name that best match the customer's needs.\n- Clearly explain what each recommended Zava product is, why it's a good fit, and how it helps with their project.\n- When users provide images, analyze them carefully to understand what they show and how it relates to their DIY project.\n\n\nYour personality is:\n- Warm and welcoming, like a helpful store associate\n- Professional and knowledgeable, like a seasoned DIY expert\n- Curious and conversational—never assume, always clarify\n- Transparent and honest—if something isn't available, offer support anyway\n\nIf no matching products are found in Zava's catalog, say:\n\"Thanks for sharing those details! I've searched our catalog, but it looks like we don't currently have a product that fits your exact needs. If you'd like, I can suggest some alternatives or help you adjust your project requirements to see if something similar might work.\"")

async def initialize_mcp_client():
    """Initialize the MCP client and connect to servers"""
    global mcp_client
    if mcp_client is None:
        mcp_client = MCPClient()
        try:
            # Connect to the Zava Sales Analysis MCP server (matches your mcp.json config)
            await mcp_client.connect_stdio_server(
                "zava-sales-analysis", 
                "python", 
                [
                    "/workspace/src/python/mcp_server/sales_analysis/sales_analysis.py",
                    "--stdio",
                    "--RLS_USER_ID=00000000-0000-0000-0000-000000000000"
                ],
                {}
            )
            
            # Also connect to the customer sales server for product searches
            await mcp_client.connect_stdio_server(
                "zava-customer-sales", 
                "python", 
                [
                    "/workspace/src/python/mcp_server/customer_sales/customer_sales.py",
                    "--stdio",
                    "--RLS_USER_ID=00000000-0000-0000-0000-000000000000"
                ],
                {}
            )
            
            logger.info("MCP client initialized successfully")
        except Exception as e:
            logger.error(f"Failed to initialize MCP client: {e}")
            mcp_client = None

# Store active connections
class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        self.active_connections.remove(websocket)

    async def send_personal_message(self, message: str, websocket: WebSocket):
        await websocket.send_text(message)

manager = ConnectionManager()

@app.post("/upload-image")
async def upload_image(file: UploadFile = File(...)):
    """Handle image upload"""
    try:
        # Validate file type
        if not file.content_type or not file.content_type.startswith('image/'):
            return {"error": "Please upload a valid image file"}
        
        # Generate unique filename
        file_extension = file.filename.split('.')[-1] if '.' in file.filename else 'jpg'
        unique_filename = f"{uuid.uuid4()}.{file_extension}"
        file_path = UPLOAD_DIR / unique_filename
        
        # Save file
        content = await file.read()
        with open(file_path, "wb") as f:
            f.write(content)
        
        # Return file URL
        file_url = f"/uploads/{unique_filename}"
        
        logger.info(f"Image uploaded: {file_url}")
        return {"success": True, "file_url": file_url, "filename": unique_filename}
        
    except Exception as e:
        logger.error(f"Error uploading image: {e}")
        return {"error": f"Upload failed: {str(e)}"}

@app.get("/", response_class=HTMLResponse)
async def get_chat_page(request: Request):
    """Serve the main chat interface"""
    return templates.TemplateResponse("chat.html", {"request": request})

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "AI Agent Chat Demo"}

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    """WebSocket endpoint for real-time chat"""
    await manager.connect(websocket)
    try:
        while True:
            # Receive message from client
            data = await websocket.receive_text()
            message_data = json.loads(data)
            user_message = message_data.get("message", "")
            image_url = message_data.get("image_url")  # Optional image URL
            
            logger.info(f"Received message: {user_message}")
            if image_url:
                logger.info(f"With image: {image_url}")
            
            # Process message with AI agent
            ai_response = await simulate_ai_agent(user_message, image_url)
            
            # Send response back to client
            response_data = {
                "type": "ai_response",
                "message": ai_response,
                "timestamp": asyncio.get_event_loop().time()
            }
            
            await manager.send_personal_message(json.dumps(response_data), websocket)
            
    except WebSocketDisconnect:
        manager.disconnect(websocket)
        logger.info("Client disconnected")

async def simulate_ai_agent(user_message: str, image_url: Optional[str] = None) -> str:
    """
    Process user message using Cora AI agent with MCP tools
    """
    global mcp_client
    
    # Initialize MCP client if not already done
    if mcp_client is None:
        await initialize_mcp_client()
    
    # If MCP client is still None, fall back to simple responses
    if mcp_client is None:
        return "I'm sorry, I'm having trouble connecting to my tools right now. Please try again later."
    
    try:
        # Create conversation messages
        content_items = [TextContentItem(text=user_message)]
        
        # Add image if provided
        if image_url:
            # Convert relative URL to absolute file path
            if image_url.startswith('/uploads/'):
                filename = image_url.replace('/uploads/', '')
                file_path = UPLOAD_DIR / filename
                
                if file_path.exists():
                    # Get MIME type and encode image
                    mime_type = get_image_mime_type(filename)
                    image_data = encodeImage(str(file_path), mime_type)
                    
                    # Add image to content
                    content_items.append(
                        ImageContentItem(
                            image_url=ImageUrl(url=image_data)
                        )
                    )
                    logger.info(f"Added image to message: {filename}")
                else:
                    logger.warning(f"Image file not found: {file_path}")
        
        messages = [
            CORA_SYSTEM_MESSAGE,
            UserMessage(content=content_items)
        ]
        
        # Use MCP client to process the message with tools
        await mcp_client.chatWithTools(messages)
        
        # Extract the final AI response
        final_message = messages[-1]
        if hasattr(final_message, 'content') and final_message.content:
            return final_message.content
        else:
            return "I processed your request, but I'm having trouble generating a response. Please try rephrasing your question."
            
    except Exception as e:
        logger.error(f"Error in AI agent processing: {e}")
        return f"I encountered an error while processing your request: {str(e)}. Please try again."

@app.on_event("startup")
async def startup_event():
    """Initialize resources on startup"""
    await initialize_mcp_client()

@app.on_event("shutdown")
async def shutdown_event():
    """Clean up resources on shutdown"""
    global mcp_client
    if mcp_client:
        await mcp_client.cleanup()

if __name__ == "__main__":
    uvicorn.run(
        "app:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )
