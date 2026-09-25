<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Core\Support\SpaShell;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class SpaController extends Controller
{
    public function __invoke(Request $request, SpaShell $shell): Response
    {
        $index = resource_path('spa/index.html');
        if (! is_file($index)) {
            return response(
                "فرانت ساخته نشده است. در پوشه frontend یک بار npm run build را اجرا کنید.\nFrontend build is missing. Run npm run build inside the frontend folder.\n",
                503,
            )->header('Content-Type', 'text/plain; charset=UTF-8');
        }

        $html = file_get_contents($index);
        if ($html === false) {
            return response('Frontend shell could not be read.', 500)
                ->header('Content-Type', 'text/plain; charset=UTF-8');
        }

        return response($shell->render($html, $request->getBasePath()), 200, [
            'Content-Type' => 'text/html; charset=UTF-8',
            'Cache-Control' => 'no-cache, no-store, must-revalidate',
        ]);
    }
}
