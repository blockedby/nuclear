import { vi } from 'vitest';

import { registerBuiltInCoreSettings } from '../../services/coreSettings';
import { resetInMemoryTauriStore } from '../../test/utils/inMemoryTauriStore';
import { SettingsWrapper } from './Settings.test-wrapper';

window.scrollTo = vi.fn();

describe('Settings view', async () => {
  beforeEach(() => {
    resetInMemoryTauriStore();
    registerBuiltInCoreSettings();
  });
  it('(Snapshot) renders the settings view', async () => {
    const { getByRole } = await SettingsWrapper.mount();
    expect(getByRole('dialog')).toMatchSnapshot();
  });

  it('shows tray window behavior settings in General preferences', async () => {
    const { getByText } = await SettingsWrapper.mount();

    expect(getByText('Close to tray')).toBeInTheDocument();
    expect(getByText('Minimize to tray')).toBeInTheDocument();
    expect(
      getByText(
        'Keep Nuclear running in the system tray when the window is closed. Use Quit from the tray menu to exit.',
      ),
    ).toBeInTheDocument();
    expect(
      getByText('Hide the window to the system tray when it is minimized.'),
    ).toBeInTheDocument();
  });
});
