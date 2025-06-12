use crate::components::templates::{self, GlobalInfo, UserInfo};
use crate::lib::users::{AuthSession, Backend};
use axum::Router;
use axum::response::IntoResponse;
use axum::routing::get;
use axum_htmx::HxBoosted;
use axum_login::login_required;
use http::StatusCode;

pub fn admin_router() -> Router {
    Router::new()
        .route("/", get(admin_homepage))
        .route_layer(login_required!(Backend, login_url = "/login"))
}

pub async fn admin_homepage(
    HxBoosted(boosted): HxBoosted,
    auth_session: AuthSession,
) -> impl IntoResponse {
    match auth_session.user {
        Some(user) => {
            let info: GlobalInfo = GlobalInfo {
                title: "Admin Panel".to_string(),
                user_info: Some(UserInfo {
                    username: user.username,
                }),
            };
            templates::admin_html(&info, boosted).into_response()
        }
        None => StatusCode::INTERNAL_SERVER_ERROR.into_response(),
    }
}
