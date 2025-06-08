// src/components/templates/mod.rs
// Top-level template module

pub mod global;
pub mod base;
pub mod admin;
pub mod login;

// Re-exports for easy access
pub use global::{GlobalInfo, UserInfo};
pub use base::base;
pub use admin::{admin_full, admin_partial};
pub use login::login;
