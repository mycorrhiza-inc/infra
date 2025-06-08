use maud::{DOCTYPE, Markup, PreEscaped, html};
pub struct GlobalInfo {
    pub title: String,
    pub user_info: Option<UserInfo>,
}

pub struct UserInfo {
    pub username: String,
}

/// Renders the base HTML layout with a title and content.
pub fn base(global_info: &GlobalInfo, content: Markup) -> Markup {
    html! {
        (DOCTYPE)
        html lang="en" {
            head {
                meta charset="UTF-8";
                meta name="viewport" content="width=device-width, initial-scale=1.0";
                title { (global_info.title) }
                link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css";
            }
            body {
                nav.navbar.navbar-expand-lg.bg-light {
                    div.container-fluid {
                        a.navbar-brand href="/" { "Dashboard" }
                        div.collapse.navbar-collapse {
                            ul.navbar-nav.me-auto.mb-2.mb-lg-0 {
                                @if let Some(_) = global_info.user_info {
                                    li.nav-item { a.nav-link href="/" { "Admin" } }
                                    li.nav-item { a.nav-link href="/logout" { "Logout" } }
                                } @else {
                                    li.nav-item { a.nav-link href="/signup" { "Sign Up" } }
                                    li.nav-item { a.nav-link href="/login" { "Sign In" } }
                                }
                            }
                        }
                    }
                }
                div.container.mt-4 {
                    (content)
                }
                script src="https://unpkg.com/htmx.org@1.9.2" {}
            }
        }
    }
}

/// Renders the full admin dashboard page.
pub fn admin_full(info: &GlobalInfo) -> Markup {
    base(info, admin_partial(info))
}

/// Renders only the admin dashboard content for HTMX partial updates.
pub fn admin_partial(info: &GlobalInfo) -> Markup {
    let username = &info.user_info.as_ref().unwrap().username;
    html! {
        h1 { "Welcome, " (username) "!" }
        p { "This is the admin dashboard content (partial)." }
    }
}

/// Renders the login page.
pub fn login(next: Option<&str>) -> Markup {
    let info = GlobalInfo {
        title: "Login".to_string(),
        user_info: None,
    };
    base(
        &info,
        html! {
                form method="post" {
                    fieldset {
                        legend { "User login" }
                        p {
                            label for="username" { "Username" }
                            input name="username" id="username" value="ferris";
                        }
                        p {
                            label for="password" { "Password" }
                            input type="password" name="password" id="password" value="hunter42";
                        }
                    }
                    input type="submit" value="login";
                    @if let Some(next_val) = next {
                        input type="hidden" name="next" value=(next_val);
                    }
                }
        },
    )
}
