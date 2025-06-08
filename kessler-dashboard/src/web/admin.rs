use crate::{users::AuthSession, web::templates};
use axum::{Router, response::IntoResponse, routing::get};
use axum_htmx::HxBoosted;
use http::StatusCode;

/// Mount the /admin route
pub fn router() -> Router<()> {
    Router::new().route("/admin", get(admin))
}

pub async fn admin(HxBoosted(boosted): HxBoosted, auth_session: AuthSession) -> impl IntoResponse {
    match auth_session.user {
        Some(user) => {
            if boosted {
                templates::admin_partial(&user.username).into_response()
            } else {
                templates::admin(&user.username).into_response()
            }
        }
        None => StatusCode::INTERNAL_SERVER_ERROR.into_response(),
    }
}
