<?php

namespace Tests\Feature;

// use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    /**
     * A basic test example.
     */
    public function test_the_application_returns_a_successful_response(): void
    {
        $response = $this->get('/');

        $response->assertOk();
        $response->assertSee('id="app"', false);
        $response->assertSee('window.__VCOS_BASE__', false);
    }

    public function test_client_routes_return_the_frontend_and_api_misses_do_not(): void
    {
        $this->get('/login')->assertOk()->assertSee('id="app"', false);
        $this->get('/api/v1/missing-route')->assertNotFound();
    }
}
