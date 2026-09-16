/*
----------------------------------------
RIG Framework (built for CFX Platforms)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
*/

// Imports

import { Modal } from "./modal/js/modal.js";
import { Notify } from "./notify/js/notify.js";
import { UIBuilder } from "./framework/js/main.js";
import { ProgressCircle } from "./progressbar/js/circle.js";
import { ProgressBar } from "./progressbar/js/bar.js"
import { SlotPopup } from "./framework/js/components/inventory_popup.js";
import { QuickMenu } from "./menus/js/quickmenu.js"
import { RadialMenu } from "./menus/js/radialmenu.js";

// Initialisation

const NOTIFY = new Notify({
    position: "right-top",
    fill_direction: "up"
});

const inventory_popup = new SlotPopup({ position: "bottom-center" });

let quickmenu = null;
let radial = null;

const HANDLERS = {}

// Handler Functions

/** Notify */

HANDLERS.notify = (data) => {
    if (!data || !data.payload) {
        console.warn("[Notify] Missing payload.");
        return;
    }

    NOTIFY.show(data.payload);
};

/** Modal */

HANDLERS.build_modal = (data) => {
    if (!data || !data.payload) {
        console.warn("[Modal] Missing payload.");
        return;
    }

    Modal.show({
        title: data.payload.title,
        options: data.payload.options || [],
        buttons: data.payload.buttons || []
    });
};

HANDLERS.remove_modal = (data) => {
    const container = data && data.payload && data.payload.container ? data.payload.container : "#ui_focus";
    Modal.remove(container);
};

/** UI Framework */

HANDLERS.build_ui = (data) => {
    if (!data.payload) {
        console.warn("[UI Builder] No UI data provided");
        return;
    }
    if (window.ui_instance && typeof window.ui_instance.destroy === "function") {
        window.ui_instance.destroy();
        window.ui_instance = null;
    }
    const builder = new UIBuilder(data.payload);
    window.ui_instance = builder;
    window.ui_instance.tooltip?.bind_tooltips();
};

HANDLERS.close_ui = () => {
    if (window.ui_instance && typeof window.ui_instance.destroy === "function") {
        window.ui_instance.close();
        window.ui_instance.destroy();
        window.ui_instance = null;
        window.hotbar_instance = null;
    }
};

HANDLERS.update_grid = (data) => {
    if (!data || !data.items || !data.section_key) return;
    const ui = window.ui_instance;
    if (!ui || !ui.content) return;
    ui.content.update_grid_from_server(data.items, data.section_key);
};

HANDLERS.update_slots = (data) => {
    if (!data || !data.items) return;
    const ui = window.ui_instance;
    if (!ui || !ui.content) return;
    ui.content.update_slots_from_server(data.items);
};

/** Inventory */

HANDLERS.build_hotbar = (data) => {
    if (window.hotbar_ui_instance && typeof window.hotbar_ui_instance.destroy === "function") {
        window.hotbar_ui_instance.destroy();
        window.hotbar_ui_instance = null;
    }

    const config = data.payload || {
        slot_count: 8,
        show_slot_numbers: true,
        layout: { slot_size: "58px" },
        items: {}
    };

    const builder = new UIBuilder({
        content: {
            pages: {},
            hotbar: config
        }
    });

    window.hotbar_ui_instance = builder;
    window.hotbar_instance = builder.content?.hotbar_instance || null;
};

HANDLERS.destroy_hotbar = () => {
    if (window.hotbar_ui_instance && typeof window.hotbar_ui_instance.destroy === "function") {
        window.hotbar_ui_instance.destroy();
        window.hotbar_ui_instance = null;
        window.hotbar_instance = null;
    }
};

HANDLERS.update_hotbar = (data) => {
    console.log("[update_hotbar] called with:", JSON.stringify(data));
    console.log("[update_hotbar] window.hotbar_instance exists:", !!window.hotbar_instance);
    console.log("[update_hotbar] window.ui_instance exists:", !!window.ui_instance);

    if (!data || !data.items) {
        console.log("[update_hotbar] bailing - no data/items");
        return;
    }
    if (window.hotbar_instance) {
        console.log("[update_hotbar] updating via hotbar_instance");
        window.hotbar_instance.update_items({ hotbar: data.items });
        return;
    }
    const ui = window.ui_instance;
    if (ui && ui.content && typeof ui.content.update_hotbar_from_server === "function") {
        console.log("[update_hotbar] updating via ui_instance.content");
        ui.content.update_hotbar_from_server(data.items);
    } else {
        console.log("[update_hotbar] no valid target found");
    }
};

HANDLERS.inventory_popup = (data) => {
    if (!data) return;
    inventory_popup.show(data.payload);
};

/** Progressbars */

HANDLERS.progress_circle = (data) => {
    new ProgressCircle(data.payload);
}

HANDLERS.progress_bar = (data) => {
    new ProgressBar(data.payload);
}

/** Menus */

HANDLERS.build_quickmenu = (data) => {
    if (!data || !data.payload) {
        console.warn("[quickmenu] Missing payload.");
        return;
    }

    if (quickmenu) {
        quickmenu.destroy();
        quickmenu = null;
    }

    quickmenu = new QuickMenu(data.payload);
    quickmenu.append_to("#ui_focus");
};

HANDLERS.close_quickmenu = () => {
    if (quickmenu) {
        quickmenu.destroy();
        quickmenu = null;
    }
};

HANDLERS.open_radial = (data) => {
    if (!data || !data.payload || !data.payload.sections) {
        console.warn("[OPEN_RADIAL] Missing sections payload.");
        return;
    }

    try {
        radial = new RadialMenu({
            sections: data.payload.sections
        });
    } catch (e) {
        console.warn("[OPEN_RADIAL] RadialMenu constructor failed:", e);
        radial = null;
        return;
    }

    radial.open();
};

HANDLERS.close_radial = () => {
    if (!radial) {
        console.warn("[CLOSE_RADIAL] Radial not initialized");
        return;
    }
    radial.close();
};

/** Utility */

HANDLERS.copy_to_clipboard = (data) => {
    const el = document.createElement('textarea');
    el.value = data.string;
    document.body.appendChild(el);
    el.select();
    document.execCommand('copy');
    document.body.removeChild(el);
};

/**
 * Global message listener for all NUI messages.
 * Routes each message to its corresponding handler.
 */
window.addEventListener("message", (event) => {
    const data = event.data;
    if (!data) return;

    if (data.type === "qm_nav" && quickmenu) {
        quickmenu.handle_nav_input(data.input);
        return;
    }

    if (data.type === "qm_update" && quickmenu) {
        quickmenu.update_dynamic_level(data.id, { items: data.items, title: data.title });
        return;
    }

    const { func } = data;
    if (!func) return;

    const handler = HANDLERS[func];

    if (typeof handler !== "function") {
        console.warn(`Handler missing: ${func}`);
        return;
    }

    handler(data);
});