import os
import time

import httpx
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

load_dotenv()
OPENROUTER_KEY = os.getenv("OPENROUTER_API_KEY", "")
BRAWL_KEY = os.getenv("BRAWL_API_KEY", "")
MODEL = os.getenv("OPENROUTER_MODEL", "meta-llama/llama-3.3-70b-instruct:free")

app = FastAPI(title="BrawlHub Server")
_cache = {"time": 0.0, "text": ""}


async def brawler_knowledge() -> str:
    """Liste à jour des brawlers (via Brawlify), mise en cache 1h."""
    if _cache["text"] and time.time() - _cache["time"] < 3600:
        return _cache["text"]
    try:
        async with httpx.AsyncClient(timeout=20) as c:
            r = await c.get("https://api.brawlify.com/v1/brawlers")
            r.raise_for_status()
        lines = []
        for b in r.json().get("list", []):
            rarity = (b.get("rarity") or {}).get("name", "?")
            klass = (b.get("class") or {}).get("name", "?")
            gadgets = ", ".join(g.get("name", "") for g in b.get("gadgets") or [])
            powers = ", ".join(s.get("name", "") for s in b.get("starPowers") or [])
            lines.append(
                f"- {b.get('name', '?').title()} ({rarity}, {klass}) "
                f"| Gadgets: {gadgets or '-'} | Star Powers: {powers or '-'}"
            )
        _cache["text"] = "\n".join(lines)
        _cache["time"] = time.time()
    except Exception:
        pass  # on garde l'ancien cache s'il existe
    return _cache["text"]


class Msg(BaseModel):
    role: str
    content: str


class ChatRequest(BaseModel):
    messages: list[Msg]


@app.get("/health")
async def health():
    return {
        "ok": True,
        "openrouter_key": bool(OPENROUTER_KEY),
        "brawl_key": bool(BRAWL_KEY),
        "model": MODEL,
    }


@app.post("/chat")
async def chat(req: ChatRequest):
    if not OPENROUTER_KEY:
        raise HTTPException(500, "OPENROUTER_API_KEY manquante dans le fichier .env")
    knowledge = await brawler_knowledge()
    system = (
        "Tu es l'assistant de l'app BrawlHub, expert de Brawl Stars. "
        "Réponds en français, de façon courte et claire. "
        "Voici la liste officielle et à jour des brawlers, utilise-la pour tes réponses "
        "(si une info n'y est pas, dis que tu ne sais pas plutôt que d'inventer) :\n"
        f"{knowledge}"
    )
    history = [
        {"role": m.role, "content": m.content}
        for m in req.messages[-20:]
        if m.role in ("user", "assistant")
    ]
    payload = {"model": MODEL, "messages": [{"role": "system", "content": system}] + history}
    async with httpx.AsyncClient(timeout=90) as c:
        r = await c.post(
            "https://openrouter.ai/api/v1/chat/completions",
            headers={"Authorization": f"Bearer {OPENROUTER_KEY}"},
            json=payload,
        )
    if r.status_code != 200:
        raise HTTPException(502, f"OpenRouter: {r.text[:300]}")
    return {"reply": r.json()["choices"][0]["message"]["content"]}


@app.get("/player/{tag}")
async def player(tag: str):
    if not BRAWL_KEY:
        raise HTTPException(500, "BRAWL_API_KEY manquante dans le fichier .env")
    tag = tag.upper().replace("#", "")
    async with httpx.AsyncClient(timeout=20) as c:
        r = await c.get(
            f"https://api.brawlstars.com/v1/players/%23{tag}",
            headers={"Authorization": f"Bearer {BRAWL_KEY}"},
        )
    if r.status_code != 200:
        raise HTTPException(r.status_code, r.text[:300])
    return r.json()
