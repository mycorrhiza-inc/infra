// Shared data structures for templates

/// Top-level information shared across pages
pub struct GlobalInfo {
    pub title: String,
    pub user_info: Option<UserInfo>,
}

/// Information about the signed-in user
pub struct UserInfo {
    pub username: String,
}
