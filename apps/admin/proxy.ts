import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

const SLOW_THRESHOLD_MS = 300

export async function proxy(request: NextRequest) {
  const start = performance.now()
  const isApi = request.nextUrl.pathname.startsWith('/api/')

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet: { name: string; value: string; options?: unknown }[]) {
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value)
          )
        },
      },
    }
  )

  const { data: { session } } = await supabase.auth.getSession()

  // Protect dashboard routes
  if (request.nextUrl.pathname.startsWith('/dashboard')) {
    if (!session) {
      return NextResponse.redirect(new URL('/auth/login', request.url))
    }
  }

  // Redirect authenticated users away from login page
  if (request.nextUrl.pathname === '/auth/login' && session) {
    return NextResponse.redirect(new URL('/dashboard', request.url))
  }

  const response = NextResponse.next()

  // API performance monitoring
  if (isApi) {
    const duration = Math.round(performance.now() - start)
    response.headers.set('X-Response-Time', `${duration}ms`)

    if (duration > SLOW_THRESHOLD_MS) {
      console.warn(`[SLOW API] ${request.method} ${request.nextUrl.pathname} — ${duration}ms`)
    }

    if (process.env.NODE_ENV === 'development') {
      console.log(`[API] ${request.method} ${request.nextUrl.pathname} — ${duration}ms`)
    }
  }

  return response
}

export const config = {
  matcher: ['/dashboard/:path*', '/auth/login', '/api/:path*'],
}
