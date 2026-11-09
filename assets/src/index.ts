import { installAvatarFallback } from "./lib/avatar-fallback";
import { installPendingGuard } from "./lib/pending";

installPendingGuard();
installAvatarFallback();

export { Collapsible } from "./components/collapsible";
export { Tabs } from "./components/tabs";
export { hooks } from "./hooks";
