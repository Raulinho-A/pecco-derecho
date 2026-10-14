from functools import lru_cache
from typing import Literal

from pydantic import SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Typed application settings read from the process environment."""

    model_config = SettingsConfigDict(
        case_sensitive=False,
        env_file=None,
        extra="ignore",
    )

    app_env: Literal["development", "test", "production"] = "development"
    log_level: Literal["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"] = "INFO"

    db_user: str = "pecco"
    db_password: SecretStr = SecretStr("pecco")
    db_name: str = "pecco"
    db_host: str = "localhost"
    db_port: int = 5432

    qdrant_host: str = "localhost"
    qdrant_port: int = 6333

    rabbitmq_user: str = "pecco"
    rabbitmq_password: SecretStr = SecretStr("pecco")
    rabbitmq_host: str = "localhost"
    rabbitmq_port: int = 5672

    ai_external_calls_enabled: bool = False
    openai_api_key: SecretStr | None = None
    openai_model: str | None = None


@lru_cache
def get_settings() -> Settings:
    return Settings()
