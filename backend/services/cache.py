# services/cache.py
import time
from typing import Any, Optional

_CACHE: dict[str, tuple[float, Any]] = {}

def get(key: str) -> Optional[Any]:
    item = _CACHE.get(key)
    if not item:
        return None

    expires_at, value = item

    # expired
    if time.time() > expires_at:
        _CACHE.pop(key, None)
        return None

    return value

# default 1 hour TTL
def set(key: str, value: Any, ttl_seconds: int = 3600) -> None:
    expires_at = time.time() + ttl_seconds
    _CACHE[key] = (expires_at, value)


def delete(key: str) -> None:
    _CACHE.pop(key, None)


def clear() -> None:
    _CACHE.clear()
