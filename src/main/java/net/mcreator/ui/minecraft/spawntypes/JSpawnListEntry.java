/*
 * MCreator (https://mcreator.net/)
 * Copyright (C) 2020 Pylo and contributors
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

package net.mcreator.ui.minecraft.spawntypes;

import net.mcreator.element.parts.EntityEntry;
import net.mcreator.element.types.Biome;
import net.mcreator.minecraft.ElementUtil;
import net.mcreator.ui.MCreator;
import net.mcreator.ui.component.JMinMaxSpinner;
import net.mcreator.ui.component.SearchableComboBox;
import net.mcreator.ui.component.util.PanelUtils;
import net.mcreator.ui.help.HelpUtils;
import net.mcreator.ui.help.IHelpContext;
import net.mcreator.ui.init.L10N;
import net.mcreator.ui.init.UIRES;
import net.mcreator.workspace.Workspace;

import javax.swing.*;
import java.awt.*;
import java.util.List;

public class JSpawnListEntry extends JPanel {

	private final JSpinner spawningProbability = new JSpinner(new SpinnerNumberModel(20, 1, 1000, 1));
	private final JMinMaxSpinner numberOfMobsPerGroup = new JMinMaxSpinner(4, 4, 1, 1000, 1);
	private final JComboBox<String> mobSpawningType = new SearchableComboBox<>(
			ElementUtil.getDataListAsStringArray("mobspawntypes"));
	private final JComboBox<String> entityType = new SearchableComboBox<>();

	private final Workspace workspace;

	public JSpawnListEntry(MCreator mcreator, IHelpContext gui, JPanel parent, List<JSpawnListEntry> entryList) {
		super(new FlowLayout(FlowLayout.LEFT));

		this.workspace = mcreator.getWorkspace();

		final JComponent container = PanelUtils.expandHorizontally(this);

		parent.add(container);
		entryList.add(this);

		ElementUtil.loadAllSpawnableEntities(workspace).forEach(e -> entityType.addItem(e.getName()));
		numberOfMobsPerGroup.setBorder(BorderFactory.createCompoundBorder(
				BorderFactory.createLineBorder((Color) UIManager.get("MCreatorLAF.LIGHT_ACCENT")),
				BorderFactory.createEmptyBorder(2, 2, 2, 2)));
		numberOfMobsPerGroup.setAllowEqualValues(true);

		add(L10N.label("dialog.spawn_list_entry.entity"));
		add(entityType);

		add(HelpUtils.wrapWithHelpButton(gui.withEntry("entity/spawn_type"),
				L10N.label("dialog.spawn_list_entry.type")));
		add(mobSpawningType);

		add(HelpUtils.wrapWithHelpButton(gui.withEntry("entity/spawn_weight"),
				L10N.label("dialog.spawn_list_entry.weight")));
		add(spawningProbability);

		add(HelpUtils.wrapWithHelpButton(gui.withEntry("entity/spawn_group_size"),
				L10N.label("dialog.spawn_list_entry.group_size")));
		add(numberOfMobsPerGroup);

		JButton remove = new JButton(UIRES.get("16px.clear"));
		remove.setText(L10N.t("dialog.spawn_list_entry.remove_entry"));
		remove.addActionListener(e -> {
			entryList.remove(this);
			parent.remove(container);
			parent.revalidate();
			parent.repaint();
		});
		add(remove);

		parent.revalidate();
		parent.repaint();
	}

	public Biome.SpawnEntry getEntry() {
		Biome.SpawnEntry entry = new Biome.SpawnEntry();
		entry.entity = new EntityEntry(workspace, (String) entityType.getSelectedItem());
		entry.spawnType = (String) mobSpawningType.getSelectedItem();
		entry.weight = (int) spawningProbability.getValue();
		entry.minGroup = numberOfMobsPerGroup.getIntMinValue();
		entry.maxGroup = numberOfMobsPerGroup.getIntMaxValue();
		return entry;
	}

	public void setEntry(Biome.SpawnEntry e) {
		entityType.setSelectedItem(e.entity.getUnmappedValue());
		mobSpawningType.setSelectedItem(e.spawnType);
		spawningProbability.setValue(e.weight);
		numberOfMobsPerGroup.setMinValue(e.minGroup);
		numberOfMobsPerGroup.setMaxValue(e.maxGroup);
	}
}
