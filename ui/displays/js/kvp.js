/*
----------------------------------------
RIG Framework (built for CFX Platforms)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
*/

export class KeyValuePairs {
    constructor() {
        this.controls = [];
        this.title = null;
        this.is_visible = false;
    }

    set_kvps(title_or_controls, controls_map = null) {
        if (controls_map === null && typeof title_or_controls === 'object' && !Array.isArray(title_or_controls)) {
            this.title = null;
            this.controls = Object.values(title_or_controls);
        } else {
            this.title = title_or_controls;
            this.controls = Object.values(controls_map || {});
        }

        $("#kv_display_section").remove();
        this.build();
        this.render_controls();
    }

    build() {
        const header_html = this.title ? `
            <div class="kv_display_header">
                <h3>${this.title}</h3>
            </div>
        ` : '';

        const content = `
            <div id="kv_display_section">
                ${header_html}
                <div class="kv_display_grid" id="kv_display_grid"></div>
            </div>
        `;
        $("#ui_focus").append(content);
    }

    render_controls() {
        if (this.title) {
            $("#kv_display_section h3").text(this.title);
        }
        
        const controls_html = this.controls.map((control, idx) => {
            return `
                <div class="kv_display_item" data-control-id="${idx}">
                    <div class="control_key">${control.key}</div>
                    <div class="control_action">${control.action}</div>
                </div>
            `;
        }).join("");
        
        $("#kv_display_grid").html(controls_html);
    }

    show() {
        if (!this.is_visible) {
            $("#kv_display_section").fadeIn(300);
            this.is_visible = true;
        }
    }

    hide() {
        if (this.is_visible) {
            $("#kv_display_section").fadeOut(300);
            this.is_visible = false;
        }
    }

    toggle() {
        if (this.is_visible) {
            this.hide();
        } else {
            this.show();
        }
    }

    destroy() {
        $("#kv_display_section").remove();
        this.is_visible = false;
    }
}