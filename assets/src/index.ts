import { installAvatarFallback } from "./lib/avatar-fallback";
import { installPendingGuard } from "./lib/pending";

installPendingGuard();
installAvatarFallback();

export { Accordion } from "./components/accordion";
export { Collapsible } from "./components/collapsible";
export { Dropdown } from "./components/dropdown";
export { Popover } from "./components/popover";
export { Tabs } from "./components/tabs";
export { Tooltip } from "./components/tooltip";
export { hooks } from "./hooks";
