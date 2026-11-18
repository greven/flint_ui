import { installAvatarFallback } from "./lib/avatar-fallback";
import { installCopy } from "./lib/copy";
import { installIndeterminate } from "./lib/indeterminate";
import { installPendingGuard } from "./lib/pending";

installPendingGuard();
installAvatarFallback();
installIndeterminate();
installCopy();

export { Accordion } from "./components/accordion";
export { Collapsible } from "./components/collapsible";
export { Dropdown } from "./components/dropdown";
export { KnownDate } from "./components/known_date";
export { Popover } from "./components/popover";
export { Slider } from "./components/slider";
export { Tabs } from "./components/tabs";
export { Tooltip } from "./components/tooltip";
export { hooks } from "./hooks";
