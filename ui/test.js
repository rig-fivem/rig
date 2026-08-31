/*
----------------------------------------
RIG Framework (built for CFX Platforms)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
*/

import { UIBuilder } from "./framework/js/main.js";
import { ProgressCircle } from "./progressbar/js/circle.js";
import { ProgressBar } from "./progressbar/js/bar.js"
import { KeyValuePairs } from "./kvp/js/kvp.js";
import { Notify } from "./notify/js/notify.js";

const make_text = (title, subtitle) => ({ type: "text", ...(title && { title }), ...(subtitle && { subtitle }) });
const make_actions = (...actions) => ({ type: "actions", actions });
const make_buttons = (...buttons) => ({ type: "buttons", buttons });
const make_modal = (title, options, buttons) => ({ title, options, buttons });
const make_btn = (id, label, action, cls = "primary", dataset = {}, modal = null) => ({
    id, label, action, class: cls, dataset, ...(modal && { modal })
});
const make_card = (title, description, layout, on_hover, buttons = []) => ({
    title, description, layout, on_hover, ...(buttons.length && { buttons })
});
const make_on_hover = (title, description, values = [], actions = [], rarity = "common") => ({
    title, description, values, actions, rarity
});

const default_dataset = { target_id: "some_target", source: "some_source" };
const modal_dataset = { source: "some_source", section: "some_section", item: "some_item" };

const shared_modal = make_modal(
    "Some Modal Title",
    [{ id: "some_option", label: "Some Option", type: "text" }],
    [
        make_btn("some_modal_button_1", "Modal Btn 1", "some_modal_action_1", "primary", modal_dataset),
        make_btn("some_modal_button_2", "Modal Btn 2", "some_modal_action_2", "secondary", modal_dataset)
    ]
);

const single_modal = make_modal(
    "Some Modal Title",
    [{ id: "some_option", label: "Some Option", type: "text" }],
    [make_btn("some_modal_button_1", "Some Label", "some_modal_action_1", "primary", modal_dataset)]
);

const card_hover_john = make_on_hover(
    "Card Info",
    ["Info descriptions can support arrays", "- like so", "- you get the idea"],
    [{ key: "Key", value: "Value Pairs" }, { key: "Name", value: "John Doe" }],
    [{ id: "test_action", key: "E", label: "Action on Keypress" }]
);

const card_hover_case = make_on_hover(
    "Card Info",
    ["Info descriptions can support arrays", "- like so", "- you get the idea"],
    [{ key: "Key", value: "Value Pairs" }, { key: "Name", value: "Case" }],
    [{ id: "test_action", key: "E", label: "Action on Keypress" }]
);

const shared_card_btn = make_btn("some_button", "Some Btn", "some_action", "primary", default_dataset, shared_modal);
const single_card_btn = make_btn("some_button", "Some Btn", "some_action", "primary", default_dataset, single_modal);

const input_groups_test = {
    index: 2,
    title: "Page 1",
    layout: { left: 3 },
    left: {
        type: "input_groups",
        title: "Page 1 Content",
        id: "test_inputs",
        layout: { columns: 1, scroll_x: "none" },
        groups: [
            {
                header: "Some Group",
                expandable: false,
                inputs: [
                    { id: "option_1", type: "number", label: "Some Option", category: "group_1" },
                    { id: "option_2", type: "text", label: "Some Other Option", placeholder: "Enter value..." }
                ]
            },
            {
                header: "Another Group",
                expandable: true,
                inputs: [
                    { id: "option_3", type: "number", label: "Yet Another Option", category: "group_2" },
                    { id: "option_4", type: "text", label: "And Another One", default: "Default Value" }
                ]
            }
        ],
        buttons: [make_btn("some_button", "Button 1", "confirm_options", "primary", { target_id: "test_button", source: "input_groups_test" })]
    }
};

const cards_test = {
    index: 1,
    title: "Page 2",
    layout: { left: 3, center: 6, right: 3 },

    left: {
        type: "cards",
        layout: { columns: 2, flex: "column", scroll_x: "none" },
        title: { text: "Left Section", span: "Span" },
        cards: [
            {
                image: "https://placehold.co/252x126",
                title: "Card In Column",
                description: "Card Description.",
                layout: "column",
                on_hover: card_hover_john,
                buttons: [shared_card_btn]
            },
            {
                image: "https://placehold.co/252x126",
                title: "Card In Column",
                description: "Card Description.",
                layout: "column",
                on_hover: card_hover_case,
                buttons: [single_card_btn]
            }
        ]
    },

    center: {
        type: "input_groups",
        title: "Select Inputs",
        id: "select_test_inputs",
        layout: { columns: 2, scroll_x: "none" },
        groups: [
            {
                header: "Select Group 1",
                expandable: false,
                inputs: [{
                    id: "select_1", type: "select", label: "Choose Option 1", value: "b", copyable: true,
                    options: [{ value: "a", label: "Option A" }, { value: "b", label: "Option B" }, { value: "c", label: "Option C" }]
                }]
            },
            {
                header: "Select Group 2",
                expandable: true,
                inputs: [{
                    id: "select_3", type: "select", label: "Another Select", value: "x",
                    options: [{ value: "x", label: "X" }, { value: "y", label: "Y" }, { value: "z", label: "Z" }]
                }]
            }
        ]
    },

    right: {
        type: "cards",
        layout: { columns: 1, flex: "row", scroll_x: "scroll", scroll_y: "scroll" },
        title: "Right Section",
        cards: [
            make_card("Card In Row", "Card Description.", undefined, make_on_hover(
                "Card Info",
                ["Info descriptions can support arrays", "- like so", "- you get the idea"],
                [{ key: "Key", value: "Value Pairs" }, { key: "Name", value: "Case" }],
                [{ id: "test_action", key: "E", label: "Action on Keypress" }],
                "rare"
            ))
        ]
    }
};

/*
const test_prog_circle = new ProgressCircle({
    message: "Repairing vehicle...",
    duration: 99,
    segments: 15,
    gap: 3
});


const test_kv_display = new KeyValuePairs();

test_kv_display.set_kvps("PLACEMENT MODE", [
    { key: 'W', action: 'Move Forward' },
    { key: 'A', action: 'Move Left' },
    { key: 'S', action: 'Move Backward' },
    { key: 'D', action: 'Move Right' },
    { key: 'G', action: 'Rotate Left' },
    { key: 'H', action: 'Rotate Right' },
    { key: 'Enter', action: 'Confirm' },
    { key: 'Backspace', action: 'Cancel' },
]);
test_kv_display.show();

const test_prog_bar = new ProgressBar({ header: "Uploading...", duration: 800000 });

const notify = new Notify({
    position: "right-center",
    fill_direction: "up"
});

notify.show({
    type: "success",
    header: "Success",
    message: "Operation completed successfully.",
    icon: "fa-solid fa-check-circle",
    duration: 50000
});

notify.show({
    type: "error",
    header: "Error",
    message: "Something went wrong.",
    icon: "fa-solid fa-times-circle",
    duration: 80000
});

notify.show({
    type: "warning",
    header: "Warning",
    message: "Some basic regular notification.",
    icon: "fa-solid fa-exclamation-circle",
    duration: 0
});

notify.show({
    type: "info",
    message: "Some basic regular notification.",
    icon: "fa-solid fa-exclamation-circle",
    duration: 0
});
*/

/*
$(document).ready(() => {
    const builder = new UIBuilder({
        header: {
            layout: { left: { justify: "flex-start" }, center: { justify: "center" }, right: { justify: "flex-end" } },
            elements: {
                left: [{ type: "group", items: [{ type: "logo", image: "/ui/assets/images/RIG256.png" }, make_text("RIG", "Framework")] }],
                center: [{ type: "tabs" }],
                right: [
                    make_buttons(
                        { id: "save", label: "Save", icon: "fa-solid fa-gear", action: "save_changes", class: "primary" },
                        { id: "exit", label: "Exit", action: "exit_builder", class: "secondary" }
                    )
                ]
            }
        },

        footer: {
            layout: { left: { justify: "flex-start", gap: "1vw" }, center: { justify: "center" }, right: { justify: "flex-end", gap: "1vw" } },
            elements: {
                left: [make_buttons(
                    {
                        id: "deploy",
                        label: "Deploy",
                        action: "deploy",
                        class: "primary",
                        modal: {
                            title: "Confirm Deploy",
                            options: [
                                { id: "deploy_name", label: "Deploy Name", type: "text", placeholder: "Enter name..." },
                                { id: "deploy_count", label: "Deploy Count", type: "number", min: 1, max: 100 }
                            ],
                            buttons: [
                                make_btn("confirm_deploy", "Confirm", "confirm_deploy", "primary", { source: "deploy_modal" }),
                                make_btn("cancel_deploy", "Cancel", "cancel_deploy", "secondary", { source: "deploy_modal" })
                            ]
                        }
                    },
                    { id: "cancel", label: "Cancel", action: "cancel", class: "secondary" }
                )],
                center: [{ type: "text", text: "Ready to deploy." }],
                right: [make_actions({ key: "ESCAPE", label: "Close" }, { key: "E", label: "Confirm" })]
            }
        },

        content: {
            pages: {
                input_groups_test,
                cards_test
            }
        }
    });
});
*/