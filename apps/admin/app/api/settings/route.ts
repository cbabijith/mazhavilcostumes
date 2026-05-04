import { NextRequest } from "next/server";
import { settingsService } from "@/services/settingsService";
import { apiGuard } from "@/lib/apiGuard";
import { getAuthUser } from "@/lib/auth";
import { apiSuccess, apiRepositoryError, apiBadRequest, apiForbidden, apiInternalError } from "@/lib/apiResponse";
import { SettingKey } from "@/domain/types/settings";

export async function GET(request: NextRequest) {
  try {
    const guard = await apiGuard(request, 'settings');
    if (guard.error) return guard.error;

    // Set the real store_id from the authenticated user
    const authUser = await getAuthUser(request);
    if (authUser?.store_id) {
      settingsService.setStoreId(authUser.store_id);
    }

    const url = new URL(request.url);
    const key = url.searchParams.get('key');
    
    if (!key) {
      const result = await settingsService.getAllSettings();
      if (!result.success) return apiRepositoryError(result.error, 'Failed to fetch settings');
      return apiSuccess({ settings: result.data });
    }

    // Special case: is_gst_enabled returns a boolean
    if (key === 'is_gst_enabled') {
      const result = await settingsService.getIsGSTEnabled();
      if (!result.success) return apiRepositoryError(result.error, 'Failed to fetch GST status');
      return apiSuccess({ value: result.data });
    }

    const result = await settingsService.findByKey(key);
    if (!result.success) {
      return apiRepositoryError(result.error, `Failed to fetch setting ${key}`);
    }
    return apiSuccess({ value: result.data?.value || null });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return apiInternalError(message);
  }
}

export async function PATCH(request: NextRequest) {
  try {
    const guard = await apiGuard(request, 'settings');
    if (guard.error) return guard.error;

    const authUser = await getAuthUser(request);
    if (!authUser || (authUser.role !== 'admin' && authUser.role !== 'super_admin')) {
      return apiForbidden('Only admin can update settings');
    }

    const body = await request.json();
    const { key, value } = body;

    if (!key || typeof value !== 'string') {
      return apiBadRequest('Key and string value are required');
    }

    settingsService.setUserContext(authUser.staff_id || null, authUser.branch_id || null);
    if (authUser.store_id) {
      settingsService.setStoreId(authUser.store_id);
    }
    const result = await settingsService.setValue(key as SettingKey, value);
    
    if (!result.success || !result.data) {
      return apiRepositoryError(result.error, 'Failed to update setting');
    }
    return apiSuccess({ value: result.data.value }, { message: 'Setting updated' });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return apiInternalError(message);
  }
}
