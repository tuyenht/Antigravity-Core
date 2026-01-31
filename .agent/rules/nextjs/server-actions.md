# Next.js Server Actions & Mutations

> **Version:** 2.0.0 | **Updated:** 2026-01-31  
> **Next.js:** 14.x / 15.x  
> **Priority:** P0 - Load for all Server Action implementations

---

You are an expert in Next.js Server Actions for secure data mutations.

## Core Server Actions Principles

- Execute code on the server directly from components
- Secure data mutations with validation
- Progressive enhancement (works without JS)
- Type safety with TypeScript

---

## 1) Basic Server Actions

### Action Definition
```tsx
// ==========================================
// INLINE ACTION (Simple)
// ==========================================

// app/page.tsx
export default function Page() {
  async function createTodo(formData: FormData) {
    'use server';
    
    const title = formData.get('title') as string;
    await db.todo.create({ data: { title } });
    revalidatePath('/');
  }

  return (
    <form action={createTodo}>
      <input name="title" required />
      <button type="submit">Add Todo</button>
    </form>
  );
}


// ==========================================
// SEPARATE FILE (Recommended)
// ==========================================

// app/actions/todos.ts
'use server';

import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';
import { db } from '@/lib/db';

export async function createTodo(formData: FormData) {
  const title = formData.get('title') as string;
  
  await db.todo.create({
    data: { title },
  });
  
  revalidatePath('/todos');
}

export async function deleteTodo(id: string) {
  await db.todo.delete({
    where: { id },
  });
  
  revalidatePath('/todos');
}

export async function updateTodo(id: string, formData: FormData) {
  const title = formData.get('title') as string;
  const completed = formData.get('completed') === 'on';
  
  await db.todo.update({
    where: { id },
    data: { title, completed },
  });
  
  revalidatePath('/todos');
}
```

---

## 2) Forms with Validation

### Zod Validation Pattern
```tsx
// ==========================================
// SCHEMA DEFINITION
// ==========================================

// lib/validations/post.ts
import { z } from 'zod';

export const CreatePostSchema = z.object({
  title: z
    .string()
    .min(1, 'Title is required')
    .max(100, 'Title must be less than 100 characters'),
  content: z
    .string()
    .min(10, 'Content must be at least 10 characters'),
  published: z
    .boolean()
    .default(false),
  categoryId: z
    .string()
    .uuid('Invalid category'),
});

export type CreatePostInput = z.infer<typeof CreatePostSchema>;


// ==========================================
// SERVER ACTION WITH VALIDATION
// ==========================================

// app/actions/posts.ts
'use server';

import { z } from 'zod';
import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';
import { auth } from '@/lib/auth';
import { db } from '@/lib/db';
import { CreatePostSchema } from '@/lib/validations/post';

// Define return type for form state
export type ActionState = {
  success: boolean;
  message: string;
  errors?: {
    title?: string[];
    content?: string[];
    categoryId?: string[];
    _form?: string[];  // General form errors
  };
  data?: { id: string };
};

export async function createPost(
  prevState: ActionState,
  formData: FormData
): Promise<ActionState> {
  // 1. Authentication
  const session = await auth();
  if (!session?.user) {
    return {
      success: false,
      message: 'Unauthorized',
      errors: { _form: ['You must be logged in'] },
    };
  }

  // 2. Parse form data
  const rawData = {
    title: formData.get('title'),
    content: formData.get('content'),
    published: formData.get('published') === 'on',
    categoryId: formData.get('categoryId'),
  };

  // 3. Validate
  const validatedFields = CreatePostSchema.safeParse(rawData);

  if (!validatedFields.success) {
    return {
      success: false,
      message: 'Validation failed',
      errors: validatedFields.error.flatten().fieldErrors,
    };
  }

  // 4. Database operation
  try {
    const post = await db.post.create({
      data: {
        ...validatedFields.data,
        authorId: session.user.id,
      },
    });

    // 5. Revalidate cache
    revalidatePath('/posts');
    revalidatePath(`/posts/${post.id}`);

    return {
      success: true,
      message: 'Post created successfully',
      data: { id: post.id },
    };
  } catch (error) {
    console.error('Create post error:', error);
    return {
      success: false,
      message: 'Database error',
      errors: { _form: ['Failed to create post. Please try again.'] },
    };
  }
}


// ==========================================
// FORM COMPONENT
// ==========================================

// app/posts/new/page.tsx
'use client';

import { useFormState, useFormStatus } from 'react-dom';
import { useEffect, useRef } from 'react';
import { useRouter } from 'next/navigation';
import { createPost, ActionState } from '@/app/actions/posts';

// Submit button with pending state
function SubmitButton() {
  const { pending } = useFormStatus();
  
  return (
    <button
      type="submit"
      disabled={pending}
      className="btn btn-primary"
    >
      {pending ? (
        <>
          <span className="loading loading-spinner" />
          Creating...
        </>
      ) : (
        'Create Post'
      )}
    </button>
  );
}

// Error display component
function FieldError({ errors }: { errors?: string[] }) {
  if (!errors?.length) return null;
  
  return (
    <div className="text-red-500 text-sm mt-1">
      {errors.map((error, i) => (
        <p key={i}>{error}</p>
      ))}
    </div>
  );
}

export default function NewPostPage() {
  const router = useRouter();
  const formRef = useRef<HTMLFormElement>(null);
  
  const initialState: ActionState = {
    success: false,
    message: '',
    errors: {},
  };
  
  const [state, formAction] = useFormState(createPost, initialState);

  // Handle success - redirect
  useEffect(() => {
    if (state.success && state.data?.id) {
      router.push(`/posts/${state.data.id}`);
    }
  }, [state, router]);

  return (
    <div className="max-w-2xl mx-auto p-6">
      <h1 className="text-2xl font-bold mb-6">Create New Post</h1>

      {/* Form-level errors */}
      <FieldError errors={state.errors?._form} />

      <form ref={formRef} action={formAction} className="space-y-4">
        <div>
          <label htmlFor="title" className="block font-medium">
            Title
          </label>
          <input
            id="title"
            name="title"
            type="text"
            className="input input-bordered w-full"
            aria-describedby={state.errors?.title ? 'title-error' : undefined}
          />
          <FieldError errors={state.errors?.title} />
        </div>

        <div>
          <label htmlFor="content" className="block font-medium">
            Content
          </label>
          <textarea
            id="content"
            name="content"
            rows={6}
            className="textarea textarea-bordered w-full"
          />
          <FieldError errors={state.errors?.content} />
        </div>

        <div>
          <label htmlFor="categoryId" className="block font-medium">
            Category
          </label>
          <select
            id="categoryId"
            name="categoryId"
            className="select select-bordered w-full"
          >
            <option value="">Select category</option>
            <option value="uuid-1">Technology</option>
            <option value="uuid-2">Design</option>
          </select>
          <FieldError errors={state.errors?.categoryId} />
        </div>

        <div className="flex items-center gap-2">
          <input
            id="published"
            name="published"
            type="checkbox"
            className="checkbox"
          />
          <label htmlFor="published">Publish immediately</label>
        </div>

        <div className="flex justify-end gap-2">
          <button
            type="button"
            onClick={() => router.back()}
            className="btn btn-ghost"
          >
            Cancel
          </button>
          <SubmitButton />
        </div>
      </form>
    </div>
  );
}
```

---

## 3) Optimistic Updates

### useOptimistic Pattern
```tsx
// ==========================================
// OPTIMISTIC TODO LIST
// ==========================================

// app/actions/todos.ts
'use server';

import { revalidatePath } from 'next/cache';

export async function toggleTodo(id: string, completed: boolean) {
  // Simulate slow network
  await new Promise(resolve => setTimeout(resolve, 1000));
  
  await db.todo.update({
    where: { id },
    data: { completed },
  });
  
  revalidatePath('/todos');
}

export async function addTodo(formData: FormData) {
  const title = formData.get('title') as string;
  
  await db.todo.create({
    data: { title, completed: false },
  });
  
  revalidatePath('/todos');
}


// app/todos/page.tsx
'use client';

import { useOptimistic, useRef } from 'react';
import { toggleTodo, addTodo } from '@/app/actions/todos';

interface Todo {
  id: string;
  title: string;
  completed: boolean;
}

type OptimisticAction =
  | { type: 'toggle'; id: string }
  | { type: 'add'; todo: Todo };

export function TodoList({ todos }: { todos: Todo[] }) {
  const formRef = useRef<HTMLFormElement>(null);

  const [optimisticTodos, addOptimistic] = useOptimistic(
    todos,
    (state: Todo[], action: OptimisticAction) => {
      switch (action.type) {
        case 'toggle':
          return state.map(todo =>
            todo.id === action.id
              ? { ...todo, completed: !todo.completed }
              : todo
          );
        case 'add':
          return [...state, action.todo];
        default:
          return state;
      }
    }
  );

  async function handleToggle(todo: Todo) {
    // Optimistic update first
    addOptimistic({ type: 'toggle', id: todo.id });
    
    // Then server action
    await toggleTodo(todo.id, !todo.completed);
  }

  async function handleAdd(formData: FormData) {
    const title = formData.get('title') as string;
    
    // Optimistic add
    addOptimistic({
      type: 'add',
      todo: {
        id: `temp-${Date.now()}`,  // Temporary ID
        title,
        completed: false,
      },
    });
    
    // Clear form
    formRef.current?.reset();
    
    // Server action
    await addTodo(formData);
  }

  return (
    <div>
      <form ref={formRef} action={handleAdd} className="flex gap-2 mb-4">
        <input
          name="title"
          placeholder="Add todo..."
          className="input input-bordered flex-1"
          required
        />
        <button type="submit" className="btn btn-primary">
          Add
        </button>
      </form>

      <ul className="space-y-2">
        {optimisticTodos.map(todo => (
          <li
            key={todo.id}
            className={`flex items-center gap-2 p-2 rounded ${
              todo.id.startsWith('temp-') ? 'opacity-50' : ''
            }`}
          >
            <input
              type="checkbox"
              checked={todo.completed}
              onChange={() => handleToggle(todo)}
              className="checkbox"
            />
            <span className={todo.completed ? 'line-through' : ''}>
              {todo.title}
            </span>
          </li>
        ))}
      </ul>
    </div>
  );
}
```

---

## 4) File Uploads

### File Upload with Server Actions
```tsx
// ==========================================
// FILE UPLOAD ACTION
// ==========================================

// app/actions/upload.ts
'use server';

import { writeFile, mkdir } from 'fs/promises';
import { join } from 'path';
import { v4 as uuid } from 'uuid';
import { z } from 'zod';

const MAX_FILE_SIZE = 5 * 1024 * 1024;  // 5MB
const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'image/webp'];

const FileSchema = z.instanceof(File).refine(
  file => file.size <= MAX_FILE_SIZE,
  'File size must be less than 5MB'
).refine(
  file => ALLOWED_TYPES.includes(file.type),
  'Only JPEG, PNG, and WebP images are allowed'
);

export type UploadState = {
  success: boolean;
  message: string;
  url?: string;
  errors?: string[];
};

export async function uploadImage(
  prevState: UploadState,
  formData: FormData
): Promise<UploadState> {
  const file = formData.get('file') as File | null;

  if (!file || file.size === 0) {
    return {
      success: false,
      message: 'No file provided',
      errors: ['Please select a file'],
    };
  }

  // Validate file
  const validatedFile = FileSchema.safeParse(file);
  if (!validatedFile.success) {
    return {
      success: false,
      message: 'Validation failed',
      errors: validatedFile.error.errors.map(e => e.message),
    };
  }

  try {
    // Create unique filename
    const ext = file.name.split('.').pop();
    const filename = `${uuid()}.${ext}`;
    
    // Ensure upload directory exists
    const uploadDir = join(process.cwd(), 'public', 'uploads');
    await mkdir(uploadDir, { recursive: true });
    
    // Save file
    const filepath = join(uploadDir, filename);
    const bytes = await file.arrayBuffer();
    await writeFile(filepath, Buffer.from(bytes));

    return {
      success: true,
      message: 'File uploaded successfully',
      url: `/uploads/${filename}`,
    };
  } catch (error) {
    console.error('Upload error:', error);
    return {
      success: false,
      message: 'Upload failed',
      errors: ['Failed to save file. Please try again.'],
    };
  }
}


// ==========================================
// UPLOAD FORM COMPONENT
// ==========================================

// components/ImageUpload.tsx
'use client';

import { useFormState, useFormStatus } from 'react-dom';
import { useState, useRef } from 'react';
import Image from 'next/image';
import { uploadImage, UploadState } from '@/app/actions/upload';

function UploadButton() {
  const { pending } = useFormStatus();
  
  return (
    <button
      type="submit"
      disabled={pending}
      className="btn btn-primary"
    >
      {pending ? 'Uploading...' : 'Upload'}
    </button>
  );
}

export function ImageUpload() {
  const [preview, setPreview] = useState<string | null>(null);
  const inputRef = useRef<HTMLInputElement>(null);
  
  const initialState: UploadState = {
    success: false,
    message: '',
  };
  
  const [state, formAction] = useFormState(uploadImage, initialState);

  function handleFileChange(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setPreview(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  }

  return (
    <div className="space-y-4">
      <form action={formAction} className="space-y-4">
        <div
          className="border-2 border-dashed rounded-lg p-8 text-center cursor-pointer hover:border-primary"
          onClick={() => inputRef.current?.click()}
        >
          {preview ? (
            <Image
              src={preview}
              alt="Preview"
              width={200}
              height={200}
              className="mx-auto object-cover"
            />
          ) : (
            <p>Click to select an image</p>
          )}
          
          <input
            ref={inputRef}
            type="file"
            name="file"
            accept="image/jpeg,image/png,image/webp"
            onChange={handleFileChange}
            className="hidden"
          />
        </div>

        {preview && <UploadButton />}
      </form>

      {/* Results */}
      {state.success && state.url && (
        <div className="alert alert-success">
          <p>{state.message}</p>
          <Image
            src={state.url}
            alt="Uploaded"
            width={100}
            height={100}
          />
        </div>
      )}

      {state.errors && (
        <div className="alert alert-error">
          {state.errors.map((error, i) => (
            <p key={i}>{error}</p>
          ))}
        </div>
      )}
    </div>
  );
}
```

---

## 5) Delete Actions with Confirmation

### Delete Pattern
```tsx
// ==========================================
// DELETE ACTION
// ==========================================

// app/actions/posts.ts
'use server';

import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';
import { auth } from '@/lib/auth';

export async function deletePost(id: string) {
  const session = await auth();
  
  if (!session?.user) {
    throw new Error('Unauthorized');
  }

  // Verify ownership
  const post = await db.post.findUnique({
    where: { id },
    select: { authorId: true },
  });

  if (!post) {
    throw new Error('Post not found');
  }

  if (post.authorId !== session.user.id) {
    throw new Error('You do not have permission to delete this post');
  }

  await db.post.delete({
    where: { id },
  });

  revalidatePath('/posts');
  redirect('/posts');
}


// ==========================================
// DELETE BUTTON COMPONENT
// ==========================================

// components/DeleteButton.tsx
'use client';

import { useTransition } from 'react';
import { useRouter } from 'next/navigation';
import { deletePost } from '@/app/actions/posts';

interface Props {
  postId: string;
}

export function DeleteButton({ postId }: Props) {
  const router = useRouter();
  const [isPending, startTransition] = useTransition();

  async function handleDelete() {
    const confirmed = window.confirm(
      'Are you sure you want to delete this post? This action cannot be undone.'
    );

    if (!confirmed) return;

    startTransition(async () => {
      try {
        await deletePost(postId);
        // redirect() is called inside action
      } catch (error) {
        alert(error instanceof Error ? error.message : 'Failed to delete');
      }
    });
  }

  return (
    <button
      onClick={handleDelete}
      disabled={isPending}
      className="btn btn-error btn-sm"
    >
      {isPending ? 'Deleting...' : 'Delete'}
    </button>
  );
}


// ==========================================
// ALTERNATIVE: FORM-BASED DELETE
// ==========================================

// For progressive enhancement (works without JS)
export function DeleteForm({ postId }: { postId: string }) {
  async function handleDelete(formData: FormData) {
    'use server';
    
    const id = formData.get('id') as string;
    await deletePost(id);
  }

  return (
    <form action={handleDelete}>
      <input type="hidden" name="id" value={postId} />
      <button
        type="submit"
        className="btn btn-error btn-sm"
        onClick={(e) => {
          if (!confirm('Are you sure?')) {
            e.preventDefault();
          }
        }}
      >
        Delete
      </button>
    </form>
  );
}
```

---

## 6) Advanced Patterns

### Bound Arguments
```tsx
// ==========================================
// BOUND ARGUMENTS
// ==========================================

// app/actions/likes.ts
'use server';

import { revalidatePath } from 'next/cache';

export async function likePost(postId: string) {
  const session = await auth();
  if (!session?.user) throw new Error('Unauthorized');
  
  await db.like.create({
    data: {
      postId,
      userId: session.user.id,
    },
  });
  
  revalidatePath(`/posts/${postId}`);
}


// components/LikeButton.tsx
// Using .bind() to pre-fill arguments
export function LikeButton({ postId }: { postId: string }) {
  // Bind postId to the action
  const likeWithId = likePost.bind(null, postId);
  
  return (
    <form action={likeWithId}>
      <button type="submit" className="btn">
        ❤️ Like
      </button>
    </form>
  );
}


// ==========================================
// MULTIPLE ACTIONS IN ONE FORM
// ==========================================

export function PostActions({ postId }: { postId: string }) {
  return (
    <div className="flex gap-2">
      <form action={likePost.bind(null, postId)}>
        <button name="intent" value="like" className="btn">
          ❤️ Like
        </button>
      </form>
      
      <form action={bookmarkPost.bind(null, postId)}>
        <button name="intent" value="bookmark" className="btn">
          🔖 Save
        </button>
      </form>
      
      <form action={sharePost.bind(null, postId)}>
        <button name="intent" value="share" className="btn">
          🔗 Share
        </button>
      </form>
    </div>
  );
}
```

### Calling Actions from Event Handlers
```tsx
// ==========================================
// EVENT HANDLER USAGE
// ==========================================

'use client';

import { useTransition } from 'react';
import { updatePreferences } from '@/app/actions/settings';

export function ThemeToggle({ currentTheme }: { currentTheme: string }) {
  const [isPending, startTransition] = useTransition();

  function handleThemeChange(theme: string) {
    startTransition(async () => {
      await updatePreferences({ theme });
    });
  }

  return (
    <div className="flex gap-2">
      {['light', 'dark', 'system'].map(theme => (
        <button
          key={theme}
          onClick={() => handleThemeChange(theme)}
          disabled={isPending}
          className={`btn ${currentTheme === theme ? 'btn-primary' : 'btn-ghost'}`}
        >
          {theme}
        </button>
      ))}
    </div>
  );
}
```

---

## 7) Error Handling

### Comprehensive Error Handling
```tsx
// ==========================================
// TYPED ERROR HANDLING
// ==========================================

// lib/errors.ts
export class ActionError extends Error {
  constructor(
    message: string,
    public code: string,
    public status: number = 400
  ) {
    super(message);
    this.name = 'ActionError';
  }
}

export const errors = {
  unauthorized: () => new ActionError('Unauthorized', 'UNAUTHORIZED', 401),
  notFound: (resource: string) => 
    new ActionError(`${resource} not found`, 'NOT_FOUND', 404),
  forbidden: () => 
    new ActionError('You do not have permission', 'FORBIDDEN', 403),
  validation: (message: string) => 
    new ActionError(message, 'VALIDATION_ERROR', 422),
};


// ==========================================
// ACTION WITH ERROR HANDLING
// ==========================================

// app/actions/posts.ts
'use server';

import { errors, ActionError } from '@/lib/errors';

export type ActionResult<T = void> = 
  | { success: true; data: T }
  | { success: false; error: { code: string; message: string } };

export async function updatePost(
  id: string,
  formData: FormData
): Promise<ActionResult<{ id: string }>> {
  try {
    const session = await auth();
    if (!session?.user) {
      throw errors.unauthorized();
    }

    const post = await db.post.findUnique({
      where: { id },
      select: { authorId: true },
    });

    if (!post) {
      throw errors.notFound('Post');
    }

    if (post.authorId !== session.user.id) {
      throw errors.forbidden();
    }

    const title = formData.get('title') as string;
    if (!title || title.length < 1) {
      throw errors.validation('Title is required');
    }

    const updated = await db.post.update({
      where: { id },
      data: { title },
    });

    revalidatePath(`/posts/${id}`);

    return {
      success: true,
      data: { id: updated.id },
    };
  } catch (error) {
    if (error instanceof ActionError) {
      return {
        success: false,
        error: {
          code: error.code,
          message: error.message,
        },
      };
    }

    console.error('Unexpected error:', error);
    return {
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'An unexpected error occurred',
      },
    };
  }
}
```

---

## Best Practices Checklist

### Security
- [ ] Validate authentication inside action
- [ ] Validate authorization (ownership)
- [ ] Validate all inputs with Zod
- [ ] Never trust client data
- [ ] Sanitize user content

### Structure
- [ ] Actions in separate files
- [ ] Typed arguments and returns
- [ ] Consistent error handling
- [ ] Proper revalidation

### UX
- [ ] useFormStatus for pending
- [ ] useFormState for errors
- [ ] useOptimistic for instant feedback
- [ ] Progressive enhancement

### Performance
- [ ] Revalidate specific paths
- [ ] Use tags for fine-grained cache
- [ ] Minimal data in actions

---

**References:**
- [Server Actions](https://nextjs.org/docs/app/building-your-application/data-fetching/server-actions-and-mutations)
- [Forms and Mutations](https://nextjs.org/docs/app/building-your-application/data-fetching/forms-and-mutations)
- [useFormState](https://react.dev/reference/react-dom/hooks/useFormState)
- [useOptimistic](https://react.dev/reference/react/useOptimistic)
