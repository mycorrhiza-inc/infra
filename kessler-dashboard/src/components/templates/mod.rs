// src/components/templates/mod.rs
// Top-level template module

pub mod admin;
pub mod base;
pub mod global;
pub mod login;

// Re-exports for easy access
pub use admin::{admin_full, admin_partial};
pub use base::base;
pub use global::{GlobalInfo, UserInfo};
