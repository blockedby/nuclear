import { renderHook, waitFor } from '@testing-library/react';
import { beforeEach, expect, it, vi } from 'vitest';

import { initializeSettingsStore, setSetting } from '../stores/settingsStore';
import { resetInMemoryTauriStore } from '../test/utils/inMemoryTauriStore';
import { useTrayWindowBehavior } from './useTrayWindowBehavior';

const windowMock = vi.hoisted(() => ({
  closeHandler: undefined as
    | undefined
    | ((event: { preventDefault: () => void }) => Promise<void>),
  resizeHandler: undefined as undefined | (() => Promise<void>),
  hide: vi.fn(),
  isMinimized: vi.fn(),
  onCloseRequested: vi.fn((handler) => {
    windowMock.closeHandler = handler;
    return Promise.resolve(vi.fn());
  }),
  onResized: vi.fn((handler) => {
    windowMock.resizeHandler = handler;
    return Promise.resolve(vi.fn());
  }),
  setDecorations: vi.fn(),
}));

vi.mock('@tauri-apps/api/window', () => ({
  getCurrentWindow: () => windowMock,
}));

beforeEach(async () => {
  vi.clearAllMocks();
  windowMock.closeHandler = undefined;
  windowMock.resizeHandler = undefined;
  windowMock.isMinimized.mockResolvedValue(false);
  resetInMemoryTauriStore();
  await initializeSettingsStore();
});

it('does not intercept close or minimize when tray settings are disabled', async () => {
  renderHook(() => useTrayWindowBehavior());

  await waitFor(() => expect(windowMock.closeHandler).toBeDefined());
  const preventDefault = vi.fn();
  await windowMock.closeHandler?.({ preventDefault });
  windowMock.isMinimized.mockResolvedValue(true);
  await windowMock.resizeHandler?.();

  expect(preventDefault).not.toHaveBeenCalled();
  expect(windowMock.hide).not.toHaveBeenCalled();
});

it('hides the window on close when close to tray is enabled', async () => {
  await setSetting('core.window.closeToTray', true);

  renderHook(() => useTrayWindowBehavior());

  await waitFor(() => expect(windowMock.closeHandler).toBeDefined());
  const preventDefault = vi.fn();
  await windowMock.closeHandler?.({ preventDefault });

  expect(preventDefault).toHaveBeenCalledTimes(1);
  expect(windowMock.hide).toHaveBeenCalledTimes(1);
});

it('hides the window after minimize when minimize to tray is enabled', async () => {
  await setSetting('core.window.minimizeToTray', true);
  windowMock.isMinimized.mockResolvedValue(true);

  renderHook(() => useTrayWindowBehavior());

  await waitFor(() => expect(windowMock.resizeHandler).toBeDefined());
  await windowMock.resizeHandler?.();

  expect(windowMock.hide).toHaveBeenCalledTimes(1);
});
