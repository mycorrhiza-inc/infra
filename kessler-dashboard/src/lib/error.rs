use anyhow::Error as AnyError;
use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use thiserror::Error;

#[derive(Error, Debug)]
pub enum AppError {
    #[error(transparent)]
    Anyhow(#[from] AnyError),
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        (StatusCode::INTERNAL_SERVER_ERROR, "Internal Server Error").into_response()
    }
}