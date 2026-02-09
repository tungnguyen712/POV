import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from backend.routes import identify, wrapped, scans
import uvicorn
from backend.routes.auth import router as auth_router
from backend.routes.chat import router as chat_router
from backend.routes.profile import router as profile_router

load_dotenv()

app = FastAPI(title="Landmark Lens API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth_router)
app.include_router(chat_router)
app.include_router(identify.router)
app.include_router(wrapped.router)
app.include_router(profile_router)
app.include_router(scans.router)

@app.get("/")
async def root():
    return {"message": "Landmark Lens API", "status": "running"}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
