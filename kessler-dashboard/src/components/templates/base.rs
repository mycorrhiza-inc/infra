use maud::{DOCTYPE, Markup, html};
use crate::components::templates::global::{GlobalInfo, UserInfo};

/// Renders the base HTML layout with a title and content.
///
pub fn base(global_info: &GlobalInfo, content: Markup) -> Markup {
    html! {
        (DOCTYPE)
        html lang="en" {
            head {
                meta charset="UTF-8";
                meta name="viewport" content="width=device-width, initial-scale=1.0";
                title { (global_info.title) }
                link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/daisyui@5";
            }
            body class="drawer drawer-mobile min-h-screen bg-base-200" {
                nav class="navbar bg-base-100 shadow-lg" {
                    div class="navbar-start" {
                        a href="/" class="btn btn-ghost text-xl" { "Dashboard" }
                    }
                    div class="navbar-end" {
                        @if let Some(_user) = &global_info.user_info {
                            a href="/" class="btn btn-ghost" { "Admin" }
                            a href="/logout" class="btn btn-ghost" { "Logout" }
                        } @else {
                            a href="/signup" class="btn btn-ghost" { "Sign Up" }
                            a href="/login" class="btn btn-ghost" { "Sign In" }
                        }
                    }
                }
                main class="container mx-auto p-4" {
                    (content)
                }
            }
            script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4";
            script src="https://unpkg.com/htmx.org@2.0.4";
        }
    }
}
