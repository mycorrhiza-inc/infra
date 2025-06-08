use askama::Template;
use axum::{Router, response::Html, response::IntoResponse, routing::get};

use axum_htmx::HxBoosted;
use http::StatusCode;

use crate::users::AuthSession;

/// Full page template extending the base layout
#[derive(Template)]
#[template(path = "admin.html")]
struct AdminTemplate<'a> {
    username: &'a str,
}

/// Partial template for htmx boosted requests
#[derive(Template)]
#[template(path = "admin_partial.html")]
struct AdminPartialTemplate<'a> {
    username: &'a str,
}

/// Mount the /admin route
pub fn router() -> Router<()> {
    Router::new().route("/admin", get(admin))
}

pub async fn admin(HxBoosted(boosted): HxBoosted, auth_session: AuthSession) -> impl IntoResponse {
    match auth_session.user {
        Some(user) => {
            if boosted {
                let html = AdminPartialTemplate {
                    username: &user.username,
                }
                .render()
                .unwrap();
                Html(html).into_response()
            } else {
                let html = AdminTemplate {
                    username: &user.username,
                }
                .render()
                .unwrap();
                Html(html).into_response()
            }
        }
        None => StatusCode::INTERNAL_SERVER_ERROR.into_response(),
    }
}
