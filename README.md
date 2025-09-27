# OCaml HTTP Router with p-adic Distance Filtering

This project implements an HTTP request router using OCaml with advanced mathematical concepts including p-adic distance for dependency filtering and load balancing.

## Features

- HTTP request parsing using Angstrom
- Hash-based load balancing across multiple backend servers  
- p-adic distance calculations for request dependency filtering
- Radix sort implementation for efficient request ordering
- Lwt-based asynchronous server

## Mathematical Background

### p-adic Distance
The p-adic distance d_p(x,y) measures "closeness" based on highest power of prime p dividing |x-y|:
- d_p(x,y) = p^(-v_p(|x-y|)) where v_p is the p-adic valuation
- Used here to filter requests based on dependency relationships

### Applications
- Request dependency analysis
- Load balancing optimization
- Request priority assignment

## Building

\\\ash
# Install dependencies
opam install lwt angstrom alcotest

# Build the project  
dune build

# Run tests
dune test

# Run the server
dune exec ocaml-http-router
\\\

## Usage

The server starts on port 8080 and routes requests to backend servers on ports 8081-8083 based on path hashing.

Example requests are filtered using p-adic distance to ensure dependencies are "close" in the p-adic metric.

## Project Structure

- \src/\ - Core library modules
- \in/\ - Executable entry point  
- \	ests/\ - Unit tests
- \xamples/\ - Usage examples
- \docs/\ - Documentation
