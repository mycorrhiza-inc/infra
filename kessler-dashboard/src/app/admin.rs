use crate::users::AuthSession;
use crate::components::templates::{self, GlobalInfo, UserInfo};
use axum::response::IntoResponse;
use axum_htmx::HxBoosted;
use http::StatusCode;

pub async fn admin(HxBoosted(boosted): HxBoosted, auth_session: AuthSession) -> impl IntoResponse {
    match auth_session.user {
        Some(user) => {
            let info: GlobalInfo = GlobalInfo {
                title: "Admin Panel".to_string(),
                user_info: Some(UserInfo {
                    username: user.username,
                }),
            };
            if boosted {
                templates::admin_partial(&info).into_response()
            } else {
                templates::admin_full(&info).into_response()
            }
        }
        None => StatusCode::INTERNAL_SERVER_ERROR.into_response(),
    }
}
