use maud::{DOCTYPE, Markup, html};
pub struct GlobalInfo {
    pub title: String,
    pub user_info: Option<UserInfo>,
}

pub struct UserInfo {
    pub username: String,
}

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

pub fn admin_full(info: &GlobalInfo) -> Markup {
    base(info, admin_partial(info))
}
pub fn admin_partial(info: &GlobalInfo) -> Markup {
    let username = &info.user_info.as_ref().unwrap().username;
    html! {
        div class="space-y-6" {
            div class="flex items-center justify-between" {
                h1 class="text-3xl font-bold" { "Welcome, " (username) "!" }
            }

            div class="grid grid-cols-1 md:grid-cols-3 gap-4" {
                div class="card bg-base-100 shadow" {
                    div class="card-body" {
                        h2 class="card-title" { "Recent Activity" }
                        ul class="space-y-2" {
                            li { "User login: 5 minutes ago" }
                            li { "Settings updated" }
                            li { "New user registered" }
                        }
                    }
                }

                div class="card bg-base-100 shadow" {
                    div class="card-body" {
                        h2 class="card-title" { "System Health" }
                        div class="radial-progress text-success" style="--value:85;" { "85%" }
                        p class="text-sm" { "All systems operational" }
                    }
                }

                div class="card bg-base-100 shadow" {
                    div class="card-body" {
                        h2 class="card-title" { "Quick Actions" }
                        div class="flex flex-col gap-2" {
                            button class="btn btn-primary" { "Create New User" }
                            button class="btn btn-secondary" { "View Logs" }
                            button class="btn btn-accent" { "System Settings" }
                        }
                    }
                }
            }
        }
    }
}

pub fn login(next: Option<&str>) -> Markup {
    let info = GlobalInfo {
        title: "Login".to_string(),
        user_info: None,
    };
    base(
        &info,
        html! {
            div class="card w-96 mx-auto bg-base-100 shadow-xl" {
                div class="card-body" {
                    h2 class="card-title" { "User Login" }
                    form method="post" class="space-y-4" {
                        div class="form-control" {
                            label class="label" for="username" {
                                span class="label-text" { "Username" }
                            }
                            input type="text" name="username" id="username"
                                class="input input-bordered" required value="ferris";
                        }
                        div class="form-control" {
                            label class="label" for="password" {
                                span class="label-text" { "Password" }
                            }
                            input type="password" name="password" id="password"
                                class="input input-bordered" required value="hunter42";
                        }
                        div class="form-control mt-6" {
                            input type="submit" value="Login" class="btn btn-primary";
                        }
                        @if let Some(next_val) = next {
                            input type="hidden" name="next" value=(next_val);
                        }
                    }
                }
            }
        },
    )
}
