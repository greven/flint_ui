import { Accordion } from "./components/accordion";
import { Collapsible } from "./components/collapsible";
import { Dropdown } from "./components/dropdown";
import { KnownDate } from "./components/known_date";
import { Modal } from "./components/modal";
import { Popover } from "./components/popover";
import { Slider } from "./components/slider";
import { Tabs } from "./components/tabs";
import { Tooltip } from "./components/tooltip";

export const hooks = {
  "FlintUI.Accordion": Accordion,
  "FlintUI.Collapsible": Collapsible,
  "FlintUI.Dropdown": Dropdown,
  "FlintUI.KnownDate": KnownDate,
  "FlintUI.Modal": Modal,
  "FlintUI.Popover": Popover,
  "FlintUI.Slider": Slider,
  "FlintUI.Tabs": Tabs,
  "FlintUI.Tooltip": Tooltip,
};
