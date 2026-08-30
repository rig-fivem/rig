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
import { StatusHUD } from "./hud/js/status.js";

// Initialisation

const NOTIFY = new Notify({
    position: "right-center",
    fill_direction: "up"
});

const HANDLERS = {}

let status_hud = null;

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
};

HANDLERS.close_ui = () => {
    if (window.ui_instance && typeof window.ui_instance.destroy === "function") {
        window.ui_instance.close();
        window.ui_instance.destroy();
        window.ui_instance = null;
    }
};

/** HUD */

HANDLERS.show_status_hud = () => {
    if (!status_hud) status_hud = new StatusHUD()
    status_hud.show()
}

HANDLERS.hide_status_hud = () => {
    if (status_hud) status_hud.hide()
}

HANDLERS.update_status_hud = (data) => {
    if (!data || !data.payload) return
    if (!status_hud) status_hud = new StatusHUD()
    status_hud.update(data.payload)
}

HANDLERS.set_status_headshot = (data) => {
    if (!data || !data.payload) return
    if (!status_hud) status_hud = new StatusHUD()
    status_hud.set_headshot(data.payload.src)
}

HANDLERS.destroy_status_hud = () => {
    if (status_hud) {
        status_hud.destroy()
        status_hud = null
    }
}

/**
 * Global message listener for all NUI messages.
 * Routes each message to its corresponding handler.
 */
window.addEventListener("message", (event) => {
    const { func } = event.data;
    const handler = HANDLERS[func];

    if (typeof handler !== "function") {
        console.warn(`Handler missing: ${func}`);
        return;
    }

    handler(event.data);
});