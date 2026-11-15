import { installAvatarFallback } from "./lib/avatar-fallback";
import { installPendingGuard } from "./lib/pending";

installPendingGuard();
installAvatarFallback();

export { Accordion } from "./components/accordion";
export { Collapsible } from "./components/collapsible";
export { Tabs } from "./components/tabs";
export { Tooltip } from "./components/tooltip";
export { hooks } from "./hooks";
