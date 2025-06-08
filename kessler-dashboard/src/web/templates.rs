use maud::{html, Markup, PreEscaped};

/// Renders the base HTML layout with a title and content.
pub fn base(title: &str, content: Markup) -> Markup {
    html! {
        (PreEscaped("<!DOCTYPE html>"))
        html lang="en" {
            head {
                meta charset="UTF-8";
                meta name="viewport" content="width=device-width, initial-scale=1.0";
                title { (title) }
                link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css";
            }
            body {
                nav.navbar.navbar-expand-lg.bg-light {
                    div.container-fluid {
                        a.navbar-brand href="/" { "Dashboard" }
                        div.collapse.navbar-collapse {
                            ul.navbar-nav.me-auto.mb-2.mb-lg-0 {
                                li.nav-item { a.nav-link href="/admin" { "Admin" } }
                                li.nav-item { a.nav-link href="/logout" { "Logout" } }
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
pub fn admin(username: &str) -> Markup {
    base("Admin Dashboard", html! {
        h1 { "Welcome, " (username) "!" }
        p { "This is the admin dashboard." }
    })
}

/// Renders only the admin dashboard content for HTMX partial updates.
pub fn admin_partial(username: &str) -> Markup {
    html! {
        h1 { "Welcome, " (username) "!" }
        p { "This is the admin dashboard content (partial)." }
    }
}

/// Renders the login page.
pub fn login(messages: &[String], next: &Option<String>) -> Markup {
    html! {
        (PreEscaped("<!DOCTYPE html>"))
        html {
            head {
                title { "Login" }
                style { "label { display: block; margin-bottom: 5px; }" }
            }
            body {
                ul {
                    @for message in messages {
                        li {
                            span { strong { (message) } }
                        }
                    }
                }
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
            }
        }
    }
}
