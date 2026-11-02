/**
 * Safe stage timings for API diagnosis; contains no request or account data.
 * @module lib/apiTiming
 */
export class ApiTiming {
  private readonly started = performance.now();
  private previous = this.started;
  private readonly stages: string[] = [];

  /** Record elapsed time since the preceding stage. */
  mark(stage: 'auth' | 'data'): void {
    const now = performance.now();
    this.stages.push(`${stage};dur=${(now - this.previous).toFixed(1)}`);
    this.previous = now;
  }

  /** Attach stage durations to a response without changing its body or caching. */
  attach<T extends Response>(response: T): T {
    response.headers.set('Server-Timing', [
      ...this.stages, `total;dur=${(performance.now() - this.started).toFixed(1)}`,
    ].join(', '));
    return response;
  }
}
