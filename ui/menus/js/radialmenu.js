export class RadialMenu {
    constructor({ sections = [], scale = 1 } = {}) {
        this.container_id = "radial_menu_container";
        this.is_open = false;
        this.menu_stack = [];
        this.scale = scale;

        this.sections = JSON.parse(JSON.stringify(sections));

        this.create_container();
        this.setup_controls();
    }

    create_container() {
        if ($(`#${this.container_id}`).length) return;
        $("#ui_focus").append(`<div id="${this.container_id}" class="radial_menu_container"></div>`);
    }

    set_scale(scale) {
        this.scale = scale;
        $(`#${this.container_id} .radial_menu_svg`).css("transform", `scale(${scale})`);
    }

    build_svg(sections) {
        if (sections.length === 1) {
            return this.build_single_section_ui(sections[0]);
        }
        const size = 400;
        const center = size / 2;
        const radius = 120;
        const inner_radius = 50;
        const angle_step = 360 / sections.length;

        let svg = `<svg class="radial_menu_svg" viewBox="0 0 ${size} ${size}" width="${size}" height="${size}">`;

        sections.forEach((section, index) => {
            const start_angle = (index * angle_step - 90) * (Math.PI / 180);
            const end_angle = ((index + 1) * angle_step - 90) * (Math.PI / 180);

            const x1 = center + inner_radius * Math.cos(start_angle);
            const y1 = center + inner_radius * Math.sin(start_angle);
            const x2 = center + radius * Math.cos(start_angle);
            const y2 = center + radius * Math.sin(start_angle);
            const x3 = center + radius * Math.cos(end_angle);
            const y3 = center + radius * Math.sin(end_angle);
            const x4 = center + inner_radius * Math.cos(end_angle);
            const y4 = center + inner_radius * Math.sin(end_angle);

            const large_arc = angle_step > 180 ? 1 : 0;
            const path = `M ${x1} ${y1} L ${x2} ${y2} A ${radius} ${radius} 0 ${large_arc} 1 ${x3} ${y3} L ${x4} ${y4} A ${inner_radius} ${inner_radius} 0 ${large_arc} 0 ${x1} ${y1} Z`;

            const icon_angle = (start_angle + end_angle) / 2;
            const icon_radius = (inner_radius + radius) / 2;
            const icon_x = center + icon_radius * Math.cos(icon_angle);
            const icon_y = center + icon_radius * Math.sin(icon_angle);

            svg += `<path class="radial_slice radial_${section.type || 'default'}" d="${path}" data-section-id="${section.id}" data-action="${section.id}"/>`;

            if (section.icon) {
                svg += `<g class="radial_icon_group" data-section-id="${section.id}" data-action="${section.id}">`;
                svg += `<foreignObject x="${icon_x - 15}" y="${icon_y - 15}" width="30" height="30" pointer-events="none">`;
                svg += `<div style="display: flex; align-items: center; justify-content: center; width: 100%; height: 100%;"><i class="${section.icon}" style="font-size: 20px; color: #fff;"></i></div>`;
                svg += `</foreignObject>`;
                svg += `</g>`;
            }
        });

        const center_label = this.menu_stack.length > 0 ? 'Back' : 'Close';
        svg += `<circle class="radial_center" cx="${center}" cy="${center}" r="${inner_radius}" data-action="__center__"/>`;
        svg += `<foreignObject x="${center - inner_radius}" y="${center - inner_radius}" width="${inner_radius * 2}" height="${inner_radius * 2}" class="radial_center_label_container">`;
        svg += `<div class="radial_center_label" xmlns="http://www.w3.org/1999/xhtml">${center_label}</div>`;
        svg += `</foreignObject>`;

        svg += `</svg>`;
        return svg;
    }

    build_single_section_ui(section) {
        const size = 400;
        const center = size / 2;
        const radius = 120;
        const inner_radius = 50;

        let svg = `<svg class="radial_menu_svg" viewBox="0 0 ${size} ${size}" width="${size}" height="${size}">`;

        const path = `M ${center - radius} ${center} A ${radius} ${radius} 0 1 1 ${center + radius} ${center} A ${radius} ${radius} 0 1 1 ${center - radius} ${center}`;

        svg += `<path class="radial_slice radial_${section.type || 'default'}" d="${path}" data-section-id="${section.id}" data-action="${section.id}"/>`;

        if (section.icon) {
            svg += `<g class="radial_icon_group" data-section-id="${section.id}" data-action="${section.id}">`;
            svg += `<foreignObject x="${center - 20}" y="${center - 100}" width="40" height="40" pointer-events="none">`;
            svg += `<div style="display: flex; align-items: center; justify-content: center; width: 100%; height: 100%;"><i class="${section.icon}" style="font-size: 24px; color: #fff;"></i></div>`;
            svg += `</foreignObject>`;
            svg += `</g>`;

            svg += `<foreignObject x="${center - 80}" y="${center - 10}" width="160" height="40" pointer-events="none">`;
            svg += `<div style="display: flex; align-items: center; justify-content: center; width: 100%; height: 100%; color: #fff; font-size: 16px; text-align: center;">${section.label}</div>`;
            svg += `</foreignObject>`;
        }

        const center_label = this.menu_stack.length > 0 ? 'Back' : 'Close';
        svg += `<circle class="radial_center" cx="${center}" cy="${center}" r="${inner_radius}" data-action="__center__"/>`;
        svg += `<foreignObject x="${center - inner_radius}" y="${center - inner_radius}" width="${inner_radius * 2}" height="${inner_radius * 2}" class="radial_center_label_container">`;
        svg += `<div class="radial_center_label" xmlns="http://www.w3.org/1999/xhtml">${center_label}</div>`;
        svg += `</foreignObject>`;

        svg += `</svg>`;
        return svg;
    }

    setup_controls() {
        const self = this;

        $(document).on("keydown.radial_menu", function(e) {
            if (e.key === "Escape" && self.is_open) {
                self.close();
            }
        });
    }

    open() {
        if (this.is_open) return;
        this.is_open = true;
        $(`#${this.container_id}`).addClass("active");
        this.render_menu();
    }

    render_menu() {
        $(`#${this.container_id} .radial_menu_svg`).remove();

        const current_menu = this.menu_stack.length > 0 ? this.menu_stack[this.menu_stack.length - 1] : this.sections;

        if (current_menu.length === 0) {
            this.close();
            return;
        }

        const svg = this.build_svg(current_menu);
        $(`#${this.container_id}`).append(svg);

        if (this.scale !== 1) {
            $(`#${this.container_id} .radial_menu_svg`).css("transform", `scale(${this.scale})`);
        }

        const self = this;
        $(document).off("click.radial").on("click.radial", ".radial_slice", (e) => {
            const action = $(e.currentTarget).data("action");
            this.handle_action(action);
        });

        $(document).off("click.radial_center").on("click.radial_center", ".radial_center", (e) => {
            this.handle_action("__center__");
        });

        $(document).off("mouseenter.radial").on("mouseenter.radial", ".radial_slice", function() {
            const section_id = $(this).data("section-id");
            const section = current_menu.find(s => s.id === section_id);
            if (section) {
                $(".radial_center_label").text(section.label);
            }
        });

        $(document).off("mouseleave.radial").on("mouseleave.radial", ".radial_slice", () => {
            const center_label = this.menu_stack.length > 0 ? 'Back' : 'Close';
            $(".radial_center_label").text(center_label);
        });
    }

    extract_dataset($el) {
        const data = {};
        $.each($el.data(), (k, v) => {
            const snake_key = k.replace(/([A-Z])/g, '_$1').toLowerCase();
            data[snake_key] = v;
        });
        return data;
    }

    async send_nui_callback(action, dataset = {}, additional = {}) {
        const payload = {
            action,
            dataset,
            should_close: additional.should_close || false
        };

        const res = await fetch(`https://${GetParentResourceName()}/nui:handler`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload),
        });

        if (!res.ok) return null;
        return await res.json();
    }

    handle_action(action) {
        if (action === "__center__") {
            if (this.menu_stack.length > 0) {
                this.menu_stack.pop();
                this.render_menu();
            } else {
                this.close();
            }
            return;
        }

        const current_menu = this.menu_stack.length > 0 ? this.menu_stack[this.menu_stack.length - 1] : this.sections;
        const section = current_menu.find(s => s.id === action);

        if (section && section.submenu) {
            this.menu_stack.push(section.submenu);
            this.render_menu();
        } else if (section && section.action) {
            this.send_nui_callback(section.action, {}, { should_close: section.should_close !== false }).then(() => {
                if (section.should_close) {
                    this.close();
                }
            }).catch((err) => {
                console.error("[RadialMenu] Callback failed:", err);
                this.close();
            });
        }
    }

    refresh_menu() {
        if (this.is_open) {
            this.render_menu();
        }
    }

    close() {
        this.is_open = false;
        this.menu_stack = [];
        $(`#${this.container_id}`).removeClass("active");
        $(`#${this.container_id} .radial_menu_svg`).remove();
        $.post(`https://${GetParentResourceName()}/nui:close_radial`, JSON.stringify({}));
    }
}