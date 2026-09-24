<?php

declare(strict_types=1);

namespace App\Core\Support;

use Illuminate\Support\Str;

class Slugger
{
    public static function unique(string $name, callable $exists, string $prefix = 'item'): string
    {
        $base = Str::slug($name);
        if ($base === '') {
            $base = $prefix.'-'.Str::lower(Str::random(6));
        }

        $slug = $base;
        $i = 2;
        while ($exists($slug)) {
            $slug = $base.'-'.$i;
            $i++;
        }

        return $slug;
    }
}
