public without sharing class PostInstallScript implements InstallHandler {

    // add actions that implement the InstallAction interface to this map to have them executed on post install
    // the version is the NEW version (to which you upgrade). In your install action you have to determine what's the
    // OLD version (from which you are upgrading) to have the right behavior.

    private Map<Version, InstallAction> upgradeActionsByVersions = new Map<Version, InstallAction>();

    // add actions that implement the InstallAction interface to this map to have them executed on post install
    // the version is the version you install. Use upgradeActionsByVersions if this is an upgrade
    private Map<Version, InstallAction> installActionsByVersions = new Map<Version, InstallAction>{
        new Version(1,0) => new InstallInitialData()
    };

    public interface InstallAction {
        void execute(InstallContext context);
    }

    private class ActionExecutor {
        private Map<Version, InstallAction> actionsByVersion { get; set; }
        private InstallContext context { get; set; }

        private ActionExecutor(Map<Version, InstallAction> actionsByVersion, InstallContext context) {
            this.actionsByVersion = actionsByVersion;
            this.context = context;
        }

        private void execute() {
            for (Version version : actionsByVersion.keySet()) {
                InstallAction action = actionsByVersion.get(version);
                action.execute(context);
            }
        }

    }

    public void onInstall(InstallContext context) {
        if (context.isUpgrade()) {
            ActionExecutor upgradeExecutor = new ActionExecutor(upgradeActionsByVersions, context);
            upgradeExecutor.execute();
        } else {
            ActionExecutor installExecutor = new ActionExecutor(installActionsByVersions, context);
            installExecutor.execute();
        }

    }
}