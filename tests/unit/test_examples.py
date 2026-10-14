from unittest.mock import AsyncMock

import pytest
from pydantic import ValidationError

from pecco_derecho.config import Settings


def test_placeholder_hello_world() -> None:
    """Placeholder proving that pytest discovers the unit-test directory."""

    assert "hello" + " world" == "hello world"


@pytest.mark.asyncio
async def test_placeholder_async_dependency_mock() -> None:
    """Placeholder showing an async dependency without external calls."""

    dependency = AsyncMock(return_value={"status": "ok"})

    result = await dependency("sample-input")

    assert result == {"status": "ok"}
    dependency.assert_awaited_once_with("sample-input")


def test_settings_load_typed_environment_values(monkeypatch: pytest.MonkeyPatch) -> None:
    """Settings parse process variables without loading a secret env file."""

    monkeypatch.setenv("APP_ENV", "test")
    monkeypatch.setenv("DB_PORT", "6543")

    settings = Settings(_env_file=None)

    assert settings.app_env == "test"
    assert settings.db_port == 6543
    assert settings.ai_external_calls_enabled is False


def test_settings_reject_invalid_port(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("DB_PORT", "not-a-port")

    with pytest.raises(ValidationError):
        Settings(_env_file=None)
