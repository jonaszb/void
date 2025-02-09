# Void

## Prerequisites
- Elixir v.1.15.7 (OTP 26)
- Client ID and client secret for GitHub OAuth

## Setup
To start your Phoenix server:

  * Set environment variables for OAuth
  ```sh
  GITHUB_CLIENT_ID=your_client_id
  GITHUB_CLIENT_SECRET=your_client_secret
  ```
  * Run `mix setup` to install and setup dependencies
  * In the `assets` folder, run `npm install` to install JS dependencies
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Testing

To run unit tests, use `mix test`.

For E2E testing, navigate to `test/pw/` and run `yarn install`, then `yarn test`.
Ensure the server is running at `localhost:4000` before running E2E tests.



