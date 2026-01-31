<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// ❌ BAD: Missing Indexes
return new class extends Migration {
    public function up()
    {
        Schema::create('posts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id'); // ← NO INDEX!
            $table->string('title');
            $table->string('status'); // ← NO INDEX!
            $table->timestamp('published_at')->nullable(); // ← NO INDEX!
            $table->timestamps();
        });
    }
};

// Queries without indexes → Table scan (SLOW):
// Post::where('user_id', 123)->get();        // Scans entire table
// Post::where('status', 'published')->get();  // Scans entire table
// Performance on 1M records: 5000ms+


// ✅ GOOD: Proper Indexes
return new class extends Migration {
    public function up()
    {
        Schema::create('posts', function (Blueprint $table) {
            $table->id();

            // Indexed foreign key with constraint
            $table->foreignId('user_id')
                ->constrained()
                ->cascadeOnDelete();
            // Auto-creates index on user_id

            $table->string('title');

            // Index frequently filtered columns
            $table->string('status')->index();
            $table->timestamp('published_at')->nullable()->index();

            // Composite index for combined filters
            $table->index(['status', 'published_at']);

            $table->timestamps();
        });
    }
};

// Queries with indexes → Use index (FAST):
// Post::where('user_id', 123)->get();        // Uses user_id index
// Post::where('status', 'published')->get();  // Uses status index
// Post::where('status', 'published')
//     ->where('published_at', '>', now()->subDays(7))
//     ->get(); // Uses composite index
// Performance on 1M records: 50ms

// Impact: 5000ms → 50ms (100× faster)
// Memory: Constant (index lookup) vs. Linear (table scan)
