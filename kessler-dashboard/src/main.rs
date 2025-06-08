//! Run with
//!
//! ```not_rust
//! cargo run -p example-sqlite
//! ```
use tracing::info;
use tracing_subscriber::{EnvFilter, layer::SubscriberExt, util::SubscriberInitExt};

use crate::app::App;

mod app;
mod components;
mod lib;
mod users; // re-export of users for backwards compatibility if needed

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    tracing_subscriber::registry()
        .with(EnvFilter::new(std::env::var("RUST_LOG").unwrap_or_else(
            |_| "axum_login=debug,tower_sessions=debug,sqlx=warn,tower_http=debug".into(),
        )))
        .with(tracing_subscriber::fmt::layer())
        .try_init()?;

    info!("Attempting to serve app");
    println!("Attempting to serve app");

    App::new().await?.serve().await
}
