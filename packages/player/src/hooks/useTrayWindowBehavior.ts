import { getCurrentWindow } from '@tauri-apps/api/window';
import { useEffect } from 'react';

import { useCoreSetting } from './useCoreSetting';

export const useTrayWindowBehavior = () => {
  const [closeToTray] = useCoreSetting<boolean>('window.closeToTray');
  const [minimizeToTray] = useCoreSetting<boolean>('window.minimizeToTray');

  useEffect(() => {
    const appWindow = getCurrentWindow();

    const unlistenClose = appWindow.onCloseRequested(async (event) => {
      if (!closeToTray) {
        return;
      }

      event.preventDefault();
      await appWindow.hide();
    });

    return () => {
      void unlistenClose.then((unlisten) => unlisten());
    };
  }, [closeToTray]);

  useEffect(() => {
    const appWindow = getCurrentWindow();

    const unlistenResize = appWindow.onResized(async () => {
      if (!minimizeToTray) {
        return;
      }

      const isMinimized = await appWindow.isMinimized();
      if (isMinimized) {
        await appWindow.hide();
      }
    });

    return () => {
      void unlistenResize.then((unlisten) => unlisten());
    };
  }, [minimizeToTray]);
};
