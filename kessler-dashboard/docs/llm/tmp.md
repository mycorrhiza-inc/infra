Could you go ahead and in this rust project make a simple templated out admin dashboard using the following crates:



    axum: fast and scalable, lots of middleware from tower

    axum-htmx: helpers when dealing with htmx headers

    axum-login: user auth, has oauth2 and user permissions

    tower-sessions: save user sessions (Redis, sqlite, memory, etc.) 

    tracing: trace and instrument async logs

    anyhow: turn any error into an AppError returning: “Internal Server Error”

    askama: templating html

In the repo is already an implementation of axum-login using sqlite as a backend. I would keep that and try to transform the repo into an htmx admin dashboard.



# Axum HTMX examples:

### Example: Extractors

In this example, we'll look for the `HX-Boosted` header, which is set when
applying the [hx-boost](https://htmx.org/attributes/hx-boost/) attribute to an
element. In our case, we'll use it to determine what kind of response we send.

When is this useful? When using a templating engine, like
[minijinja](https://github.com/mitsuhiko/minijinja), it is common to extend
different templates from a `_base.html` template. However, htmx works by sending
partial responses, so extending our `_base.html` would result in lots of extra
data being sent over the wire.

If we wanted to swap between pages, we would need to support both full template
responses and partial responses _(as the page can be accessed directly or
through a boosted anchor)_, so we look for the `HX-Boosted` header and extend
from a `_partial.html` template instead.

```rust
use axum::response::IntoResponse;
use axum_htmx::HxBoosted;

async fn get_index(HxBoosted(boosted): HxBoosted) -> impl IntoResponse {
    if boosted {
        // Send a template extending from _partial.html
    } else {
        // Send a template extending from _base.html
    }
}
```

### Example: Responders

We can trigger any event being listened to by the DOM using an [htmx
trigger](https://htmx.org/attributes/hx-trigger/) header.

```rust
use axum_htmx::HxResponseTrigger;

// When we load our page, we will trigger any event listeners for "my-event.
async fn index() -> (HxResponseTrigger, &'static str) {
    // Note: As HxResponseTrigger only implements `IntoResponseParts`, we must
    // return our trigger first here.
    (
        HxResponseTrigger::normal(["my-event", "second-event"]),
        "Hello, world!",
    )
}
```

`htmx` also allows arbitrary data to be sent along with the event, which we can
use via the `serde` feature flag and the `HxEvent` type.

```rust
use serde_json::json;

// Note that we are using `HxResponseTrigger` from the `axum_htmx::serde` module
// instead of the root module.
use axum_htmx::{HxEvent, HxResponseTrigger};

async fn index() -> (HxResponseTrigger, &'static str) {
    let event = HxEvent::new_with_data(
        "my-event",
        // May be any object that implements `serde::Serialize`
        json!({"level": "info", "message": {
            "title": "Hello, world!",
            "body": "This is a test message.",
        }}),
    )
    .unwrap();

    // Note: As HxResponseTrigger only implements `IntoResponseParts`, we must
    // return our trigger first here.
    (HxResponseTrigger::normal([event]), "Hello, world!")
}
```

### Example: Router Guard

```rust
use axum::Router;
use axum_htmx::HxRequestGuardLayer;

fn router_one() -> Router {
    Router::new()
        // Redirects to "/" if the HX-Request header is not present
        .layer(HxRequestGuardLayer::default())
}

fn router_two() -> Router {
    Router::new()
        .layer(HxRequestGuardLayer::new("/redirect-to-this-route"))
}
```

