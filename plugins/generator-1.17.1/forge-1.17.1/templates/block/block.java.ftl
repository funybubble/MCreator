<#--
 # MCreator (https://mcreator.net/)
 # Copyright (C) 2012-2020, Pylo
 # Copyright (C) 2020-2021, Pylo, opensource contributors
 # 
 # This program is free software: you can redistribute it and/or modify
 # it under the terms of the GNU General Public License as published by
 # the Free Software Foundation, either version 3 of the License, or
 # (at your option) any later version.
 # 
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 # 
 # You should have received a copy of the GNU General Public License
 # along with this program.  If not, see <https://www.gnu.org/licenses/>.
 # 
 # Additional permission for code generator templates (*.ftl files)
 # 
 # As a special exception, you may create a larger work that contains part or 
 # all of the MCreator code generator templates (*.ftl files) and distribute 
 # that work under terms of your choice, so long as that work isn't itself a 
 # template for code generation. Alternatively, if you modify or redistribute 
 # the template itself, you may (at your option) remove this special exception, 
 # which will cause the template and the resulting code generator output files 
 # to be licensed under the GNU General Public License without this special 
 # exception.
-->

<#-- @formatter:off -->
<#include "../boundingboxes.java.ftl">
<#include "../mcitems.ftl">
<#include "../procedures.java.ftl">
<#include "../particles.java.ftl">

package ${package}.block;

import net.minecraft.world.level.material.Material;
import net.minecraft.sounds.SoundEvent;

public class ${name}Block extends
			<#if data.hasGravity>
					FallingBlock
			<#elseif data.blockBase?has_content && data.blockBase == "Button">
				<#if (data.material.getUnmappedValue() == "WOOD") || (data.material.getUnmappedValue() == "NETHER_WOOD")>Wood<#else>Stone</#if>ButtonBlock
			<#elseif data.blockBase?has_content>
				${data.blockBase?replace("Stairs", "Stair")?replace("Pane", "IronBars")}Block
			<#else>
				Block
			</#if>
			<#if data.isWaterloggable || data.hasInventory>
            implements
				<#if data.isWaterloggable>SimpleWaterloggedBlock</#if>
				<#if data.hasInventory><#if data.isWaterloggable>,</#if>EntityBlock</#if>
			</#if>
{

	<#if data.rotationMode == 1 || data.rotationMode == 3>
	public static final DirectionProperty FACING = HorizontalDirectionalBlock.FACING;
	<#elseif data.rotationMode == 2 || data.rotationMode == 4>
	public static final DirectionProperty FACING = DirectionalBlock.FACING;
	<#elseif data.rotationMode == 5>
	public static final EnumProperty<Direction.Axis> AXIS = BlockStateProperties.AXIS;
	</#if>
	<#if data.isWaterloggable>
	public static final BooleanProperty WATERLOGGED = BlockStateProperties.WATERLOGGED;
	</#if>

	<#macro blockProperties>
		Block.Properties.of(Material.${data.material})
			<#if data.isCustomSoundType>
				.sound(new ForgeSoundType(1.0f, 1.0f, () -> new SoundEvent(new ResourceLocation("${data.breakSound}")),
				() -> new SoundEvent(new ResourceLocation("${data.stepSound}")),
				() -> new SoundEvent(new ResourceLocation("${data.placeSound}")),
				() -> new SoundEvent(new ResourceLocation("${data.hitSound}")),
				() -> new SoundEvent(new ResourceLocation("${data.fallSound}"))))
			<#else>
				.sound(SoundType.${data.soundOnStep})
			</#if>
			<#if data.unbreakable>
				.strength(-1, 3600000)
			<#else>
				.strength(${data.hardness}f, ${data.resistance}f)
			</#if>
				.lightLevel(s -> ${data.luminance})
			<#if data.destroyTool != "Not specified">
				.requiresCorrectToolForDrops()
			</#if>
			<#if data.isNotColidable>
				.noCollission()
			</#if>
			<#if data.slipperiness != 0.6>
				.friction(${data.slipperiness}f)
			</#if>
			<#if data.speedFactor != 1.0>
				.speedFactor(${data.speedFactor}f)
			</#if>
			<#if data.jumpFactor != 1.0>
				.jumpFactor(${data.jumpFactor}f)
			</#if>
			<#if data.hasTransparency || (data.blockBase?has_content && data.blockBase == "Leaves")>
				.noOcclusion()
			</#if>
			<#if data.tickRandomly>
				.randomTicks()
			</#if>
			<#if data.emissiveRendering>
				.hasPostProcess((bs, br, bp) -> true).emissiveRendering((bs, br, bp) -> true)
			</#if>
			<#if data.hasTransparency>
				.isRedstoneConductor((bs, br, bp) -> false)
			</#if>
			<#if (data.boundingBoxes?? && !data.blockBase?? && !data.isFullCube() && data.offsetType != "NONE")
					|| (data.blockBase?has_content && data.blockBase == "Stairs")>
				.dynamicShape()
			</#if>
	</#macro>

	public ${name}Block() {
		<#if data.blockBase?has_content && data.blockBase == "Stairs">
		super(() -> new Block(<@blockProperties/>).defaultBlockState(),
		<#elseif data.blockBase?has_content && data.blockBase == "PressurePlate">
		    <#if (data.material.getUnmappedValue() == "WOOD") || (data.material.getUnmappedValue() == "NETHER_WOOD")>
		        super(Sensitivity.EVERYTHING,
		    <#else>
		        super(Sensitivity.MOBS,
		    </#if>
		<#else>
		super(
		</#if>
		<@blockProperties/>
		);

	    <#if data.rotationMode != 0 || data.isWaterloggable>
	    this.registerDefaultState(this.stateDefinition.any()
	                             <#if data.rotationMode == 1 || data.rotationMode == 3>
	                             .setValue(FACING, Direction.NORTH)
	                             <#elseif data.rotationMode == 2 || data.rotationMode == 4>
	                             .setValue(FACING, Direction.NORTH)
	                             <#elseif data.rotationMode == 5>
	                             .setValue(AXIS, Direction.Axis.Y)
	                             </#if>
	                             <#if data.isWaterloggable>
	                             .setValue(WATERLOGGED, false)
	                             </#if>
	    );
		</#if>

		setRegistryName("${registryname}");
	}

	<#if data.blockBase?has_content && data.blockBase == "Fence">
	@Override public boolean connectsTo(BlockState state, boolean checkattach, Direction face) {
	  boolean flag = state.getBlock() instanceof FenceBlock && state.getMaterial() == this.material;
	  boolean flag1 = state.getBlock() instanceof FenceGateBlock && FenceGateBlock.connectsToDirection(state, face);
	  return !isExceptionForConnection(state) && checkattach || flag || flag1;
	}
	<#elseif data.blockBase?has_content && data.blockBase == "Wall">
   private static final int WALL_WIDTH = 3;
   private static final int WALL_HEIGHT = 14;
   private static final int POST_WIDTH = 4;
   private static final int POST_COVER_WIDTH = 1;
   private static final int WALL_COVER_START = 7;
   private static final int WALL_COVER_END = 9;
   private static final VoxelShape POST_TEST = Block.box(7.0D, 0.0D, 7.0D, 9.0D, 16.0D, 9.0D);
   private static final VoxelShape NORTH_TEST = Block.box(7.0D, 0.0D, 0.0D, 9.0D, 16.0D, 9.0D);
   private static final VoxelShape SOUTH_TEST = Block.box(7.0D, 0.0D, 7.0D, 9.0D, 16.0D, 16.0D);
   private static final VoxelShape WEST_TEST = Block.box(0.0D, 0.0D, 7.0D, 9.0D, 16.0D, 9.0D);
   private static final VoxelShape EAST_TEST = Block.box(7.0D, 0.0D, 7.0D, 16.0D, 16.0D, 9.0D);

	@Override ${mcc.getMethod("net.minecraft.world.level.block.WallBlock", "getStateForPlacement", "BlockPlaceContext")}
	@Override ${mcc.getMethod("net.minecraft.world.level.block.WallBlock", "updateShape", "BlockState", "Direction", "BlockState", "LevelAccessor", "BlockPos", "BlockPos")}
	${mcc.getMethod("net.minecraft.world.level.block.WallBlock", "topUpdate", "LevelReader", "BlockState", "BlockPos", "BlockState")}
	${mcc.getMethod("net.minecraft.world.level.block.WallBlock", "sideUpdate", "LevelReader", "BlockPos", "BlockState", "BlockPos", "BlockState", "Direction")}
	${mcc.getMethod("net.minecraft.world.level.block.WallBlock", "updateShape", "LevelReader", "BlockState", "BlockPos", "BlockState", "boolean", "boolean", "boolean", "boolean")}
	${mcc.getMethod("net.minecraft.world.level.block.WallBlock", "updateSides", "BlockState", "boolean", "boolean", "boolean", "boolean", "VoxelShape")}
	${mcc.getMethod("net.minecraft.world.level.block.WallBlock", "makeWallState", "boolean", "VoxelShape", "VoxelShape")}
	${mcc.getMethod("net.minecraft.world.level.block.WallBlock", "shouldRaisePost", "BlockState", "BlockState", "VoxelShape")}

	private boolean connectsTo(BlockState state, boolean checkattach, Direction face) {
		boolean flag = state.getBlock() instanceof WallBlock || state.getBlock() instanceof FenceGateBlock && FenceGateBlock.connectsToDirection(state, face);
		return !isExceptionForConnection(state) && checkattach || flag;
	}

	private static boolean isConnected(BlockState state, Property<WallSide> heightProperty) {
		return state.getValue(heightProperty) != WallSide.NONE;
	}

	private static boolean isCovered(VoxelShape shape1, VoxelShape shape2) {
		return !Shapes.joinIsNotEmpty(shape2, shape1, BooleanOp.ONLY_FIRST);
	}
	</#if>

	<#if data.specialInfo?has_content>
	@Override public void appendHoverText(ItemStack itemstack, BlockGetter world, List<Component> list, TooltipFlag flag) {
		super.appendHoverText(itemstack, world, list, flag);
		<#list data.specialInfo as entry>
		list.add(new TextComponent("${JavaConventions.escapeStringForJava(entry)}"));
	    </#list>
	}
	</#if>

	<#if data.displayFluidOverlay>
	@Override public boolean shouldDisplayFluidOverlay(BlockState state, BlockAndTintGetter world, BlockPos pos, FluidState fluidstate) {
		return true;
	}
	</#if>

	<#if data.beaconColorModifier?has_content>
	@Override public float[] getBeaconColorMultiplier(BlockState state, LevelReader world, BlockPos pos, BlockPos beaconPos) {
		return new float[] { ${data.beaconColorModifier.getRed()/255}f, ${data.beaconColorModifier.getGreen()/255}f, ${data.beaconColorModifier.getBlue()/255}f };
	}
	</#if>

	<#if data.connectedSides>
	@Override public boolean skipRendering(BlockState state, BlockState adjacentBlockState, Direction side) {
		return adjacentBlockState.getBlock() == this ? true : super.skipRendering(state, adjacentBlockState, side);
	}
	</#if>

	<#if (!data.blockBase?has_content || data.blockBase == "Leaves") && data.lightOpacity == 0>
	@Override public boolean propagatesSkylightDown(BlockState state, BlockGetter reader, BlockPos pos) {
		return <#if data.isWaterloggable>state.getFluidState().isEmpty()<#else>true</#if>;
	}
	</#if>

	<#if !data.blockBase?has_content || data.blockBase == "Leaves" || data.lightOpacity != 15>
	@Override public int getLightBlock(BlockState state, BlockGetter worldIn, BlockPos pos) {
		return ${data.lightOpacity};
	}
	</#if>

	<#if data.boundingBoxes?? && !data.blockBase?? && !data.isFullCube()>
	@Override public VoxelShape getShape(BlockState state, BlockGetter world, BlockPos pos, CollisionContext context) {
		<#if data.isBoundingBoxEmpty()>
			return Shapes.empty();
		<#else>
			<#if !data.disableOffset>Vec3 offset = state.getOffset(world, pos);</#if>
			<@boundingBoxWithRotation data.positiveBoundingBoxes() data.negativeBoundingBoxes() data.disableOffset data.rotationMode/>
		</#if>
	}
	</#if>

	<#if data.rotationMode != 0>
	@Override protected void createBlockStateDefinition(StateDefinition.Builder<Block, BlockState> builder) {
		<#if data.isWaterloggable>
			<#if data.rotationMode == 5>
			builder.add(AXIS, WATERLOGGED);
			<#else>
			builder.add(FACING, WATERLOGGED);
			</#if>
		<#elseif data.rotationMode == 5>
			builder.add(AXIS);
		<#else>
			builder.add(FACING);
		</#if>
	}

		<#if data.rotationMode != 5>
		public BlockState rotate(BlockState state, Rotation rot) {
			return state.setValue(FACING, rot.rotate(state.getValue(FACING)));
		}

		public BlockState mirror(BlockState state, Mirror mirrorIn) {
			return state.rotate(mirrorIn.getRotation(state.getValue(FACING)));
		}
		<#else>
		@Override public BlockState rotate(BlockState state, Rotation rot) {
			if(rot == Rotation.CLOCKWISE_90 || rot == Rotation.COUNTERCLOCKWISE_90) {
				if ((Direction.Axis) state.getValue(AXIS) == Direction.Axis.X) {
					return state.setValue(AXIS, Direction.Axis.Z);
				} else if ((Direction.Axis) state.getValue(AXIS) == Direction.Axis.Z) {
					return state.setValue(AXIS, Direction.Axis.X);
				}
			}
			return state;
		}
		</#if>

	@Override
	public BlockState getStateForPlacement(BlockPlaceContext context) {
	    <#if data.rotationMode == 4>
	    Direction facing = context.getClickedFace();
	    </#if>
	    <#if data.rotationMode == 5>
	    Direction.Axis axis = context.getClickedFace().getAxis();
	    </#if>
	    <#if data.isWaterloggable>
	    boolean flag = context.getLevel().getFluidState(context.getClickedPos()).getType() == Fluids.WATER;
	    </#if>;
		<#if data.rotationMode != 3>
		return this.defaultBlockState()
		        <#if data.rotationMode == 1>
		        .setValue(FACING, context.getHorizontalDirection().getOpposite())
		        <#elseif data.rotationMode == 2>
		        .setValue(FACING, context.getNearestLookingDirection().getOpposite())
	            <#elseif data.rotationMode == 4>
		        .setValue(FACING, facing)
	            <#elseif data.rotationMode == 5>
	            .setValue(AXIS, axis)
		        </#if>
		        <#if data.isWaterloggable>
		        .setValue(WATERLOGGED, flag)
		        </#if>
		<#elseif data.rotationMode == 3>
	    if (context.getClickedFace() == Direction.UP || context.getClickedFace() == Direction.DOWN)
	        return this.defaultBlockState()
	                .setValue(FACING, Direction.NORTH)
	                <#if data.isWaterloggable>
	                .setValue(WATERLOGGED, flag)
	                </#if>;
	    return this.defaultBlockState()
	            .setValue(FACING, context.getClickedFace())
	            <#if data.isWaterloggable>
	            .setValue(WATERLOGGED, flag)
	            </#if>
		</#if>;
	}
	</#if>

	<#if hasProcedure(data.placingCondition)>
	@Override public boolean canSurvive(BlockState blockstate, LevelReader worldIn, BlockPos pos) {
		if (worldIn instanceof LevelAccessor) {
			LevelAccessor world = (LevelAccessor) worldIn;
			int x = pos.getX();
			int y = pos.getY();
			int z = pos.getZ();
			return <@procedureOBJToConditionCode data.placingCondition/>;
		}
		return super.canSurvive(blockstate, worldIn, pos);
	}
	</#if>

	<#if data.isWaterloggable>
	    <#if data.rotationMode == 0>
	    @Override
	    public BlockState getStateForPlacement(BlockPlaceContext context) {
	    boolean flag = context.getLevel().getFluidState(context.getClickedPos()).getType() == Fluids.WATER;
	        return this.defaultBlockState().setValue(WATERLOGGED, flag);
	    }
	    @Override protected void createBlockStateDefinition(StateDefinition.Builder<Block, BlockState> builder) {
	        builder.add(WATERLOGGED);
	    }
	    </#if>

	@Override public FluidState getFluidState(BlockState state) {
	    return state.getValue(WATERLOGGED) ? Fluids.WATER.getSource(false) : super.getFluidState(state);
	}
	</#if>

	<#if data.isWaterloggable || hasProcedure(data.placingCondition)>
	@Override public BlockState updateShape(BlockState state, Direction facing, BlockState facingState, LevelAccessor world, BlockPos currentPos, BlockPos facingPos) {
	    <#if data.isWaterloggable>
		if (state.getValue(WATERLOGGED)) {
			world.getLiquidTicks().scheduleTick(currentPos, Fluids.WATER, Fluids.WATER.getTickDelay(world));
		}
		</#if>
		return <#if hasProcedure(data.placingCondition)>
		!state.canSurvive(world, currentPos) ? Blocks.AIR.defaultBlockState() :
		</#if> super.updateShape(state, facing, facingState, world, currentPos, facingPos);
	}
	</#if>

	<#if data.enchantPowerBonus != 0>
	@Override public float getEnchantPowerBonus(BlockState state, LevelReader world, BlockPos pos) {
		return ${data.enchantPowerBonus}f;
	}
	</#if>

	<#if data.isReplaceable>
	@Override public boolean canBeReplaced(BlockState state, BlockPlaceContext context) {
		return context.getItemInHand().getItem() != this.asItem();
	}
	</#if>

	<#if data.canProvidePower && data.emittedRedstonePower??>
	@Override public boolean isSignalSource(BlockState state) {
		return true;
	}

	@Override public int getSignal(BlockState blockstate, BlockGetter blockAccess, BlockPos pos, Direction side) {
		<#if hasProcedure(data.emittedRedstonePower)>
			int x = pos.getX();
			int y = pos.getY();
			int z = pos.getZ();
			Level world = (Level) blockAccess;
			return (int) <@procedureOBJToNumberCode data.emittedRedstonePower/>;
		<#else>
			return ${data.emittedRedstonePower.getFixedValue()};
		</#if>
	}
	</#if>

	<#if data.flammability != 0>
	@Override public int getFlammability(BlockState state, BlockGetter world, BlockPos pos, Direction face) {
		return ${data.flammability};
	}
	</#if>

	<#if data.fireSpreadSpeed != 0>
	@Override public int getFireSpreadSpeed(BlockState state, BlockGetter world, BlockPos pos, Direction face) {
		return ${data.fireSpreadSpeed};
	}
	</#if>

	<#if data.creativePickItem?? && !data.creativePickItem.isEmpty()>
	@Override public ItemStack getPickBlock(BlockState state, HitResult target, BlockGetter world, BlockPos pos, Player player) {
		return ${mappedMCItemToItemStackCode(data.creativePickItem, 1)};
	}
	</#if>

	<#if generator.map(data.colorOnMap, "mapcolors") != "DEFAULT">
	@Override public MaterialColor defaultMaterialColor() {
		return MaterialColor.${generator.map(data.colorOnMap, "mapcolors")};
	}
	</#if>

	<#if generator.map(data.aiPathNodeType, "pathnodetypes") != "DEFAULT">
	@Override public BlockPathTypes getAiPathNodeType(BlockState state, BlockGetter world, BlockPos pos, Mob entity) {
		return BlockPathTypes.${generator.map(data.aiPathNodeType, "pathnodetypes")};
	}
	</#if>

	<#if data.offsetType != "NONE">
	@Override public Block.OffsetType getOffsetType() {
		return Block.OffsetType.${data.offsetType};
	}
	</#if>

	<#if data.plantsGrowOn>
	@Override
	public boolean canSustainPlant(BlockState state, BlockGetter world, BlockPos pos, Direction direction, IPlantable plantable) {
		return true;
	}
	</#if>

	<#if data.isLadder>
	@Override public boolean isLadder(BlockState state, LevelReader world, BlockPos pos, LivingEntity entity) {
		return true;
	}
	</#if>

	<#if data.reactionToPushing != "NORMAL">
	@Override public PushReaction getPistonPushReaction(BlockState state) {
		return PushReaction.${data.reactionToPushing};
	}
	</#if>

	<#if data.canRedstoneConnect>
	@Override
	public boolean canConnectRedstone(BlockState state, BlockGetter world, BlockPos pos, Direction side) {
		return true;
	}
	</#if>

	<#if data.destroyTool != "Not specified">
	@Override public boolean canHarvestBlock(BlockState state, BlockGetter world, BlockPos pos, Player player) {
		if(player.getInventory().getSelected().getItem() instanceof TieredItem tieredItem)
			return tieredItem.getTier().getLevel() >= ${data.breakHarvestLevel};
		return false;
	}
	</#if>

	<#if !data.useLootTableForDrops>
		<#if data.dropAmount != 1 && !(data.customDrop?? && !data.customDrop.isEmpty())>
		@Override public List<ItemStack> getDrops(BlockState state, LootContext.Builder builder) {
			<#if data.blockBase?has_content && data.blockBase == "Door">
			if(state.getValue(BlockStateProperties.DOUBLE_BLOCK_HALF) != DoubleBlockHalf.LOWER)
				return Collections.emptyList();
			</#if>

			List<ItemStack> dropsOriginal = super.getDrops(state, builder);
			if(!dropsOriginal.isEmpty())
				return dropsOriginal;
			return Collections.singletonList(new ItemStack(this, ${data.dropAmount}));
		}
		<#elseif data.customDrop?? && !data.customDrop.isEmpty()>
		@Override public List<ItemStack> getDrops(BlockState state, LootContext.Builder builder) {
			<#if data.blockBase?has_content && data.blockBase == "Door">
			if(state.getValue(BlockStateProperties.DOUBLE_BLOCK_HALF) != DoubleBlockHalf.LOWER)
				return Collections.emptyList();
			</#if>

			List<ItemStack> dropsOriginal = super.getDrops(state, builder);
			if(!dropsOriginal.isEmpty())
				return dropsOriginal;
			return Collections.singletonList(${mappedMCItemToItemStackCode(data.customDrop, data.dropAmount)});
		}
		<#elseif data.blockBase?has_content && data.blockBase == "Slab">
		@Override public List<ItemStack> getDrops(BlockState state, LootContext.Builder builder) {
			List<ItemStack> dropsOriginal = super.getDrops(state, builder);
			if(!dropsOriginal.isEmpty())
				return dropsOriginal;
			return Collections.singletonList(new ItemStack(this, state.getValue(TYPE) == SlabType.DOUBLE ? 2 : 1));
		}
		<#else>
		@Override public List<ItemStack> getDrops(BlockState state, LootContext.Builder builder) {
			<#if data.blockBase?has_content && data.blockBase == "Door">
			if(state.getValue(BlockStateProperties.DOUBLE_BLOCK_HALF) != DoubleBlockHalf.LOWER)
				return Collections.emptyList();
			</#if>

			List<ItemStack> dropsOriginal = super.getDrops(state, builder);
			if(!dropsOriginal.isEmpty())
				return dropsOriginal;
			return Collections.singletonList(new ItemStack(this, 1));
		}
		</#if>
	</#if>

	<#if (hasProcedure(data.onTickUpdate) && !data.tickRandomly) || hasProcedure(data.onBlockAdded) >
	@Override public void onPlace(BlockState blockstate, Level world, BlockPos pos, BlockState oldState, boolean moving) {
		super.onPlace(blockstate, world, pos, oldState, moving);
		int x = pos.getX();
		int y = pos.getY();
		int z = pos.getZ();
		<#if hasProcedure(data.onTickUpdate) && !data.tickRandomly>
		world.getBlockTicks().scheduleTick(new BlockPos(x, y, z), this, ${data.tickRate});
	    </#if>
		<@procedureOBJToCode data.onBlockAdded/>
	}
	</#if>

	<#if hasProcedure(data.onRedstoneOn) || hasProcedure(data.onRedstoneOff) || hasProcedure(data.onNeighbourBlockChanges)>
	@Override
	public void neighborChanged(BlockState blockstate, Level world, BlockPos pos, Block neighborBlock, BlockPos fromPos, boolean moving) {
		super.neighborChanged(blockstate, world, pos, neighborBlock, fromPos, moving);
		int x = pos.getX();
		int y = pos.getY();
		int z = pos.getZ();
		if (world.getBestNeighborSignal(new BlockPos(x, y, z)) > 0) {
			<@procedureOBJToCode data.onRedstoneOn/>
		} else {
			<@procedureOBJToCode data.onRedstoneOff/>
		}
		<@procedureOBJToCode data.onNeighbourBlockChanges/>
	}
	</#if>

	<#if hasProcedure(data.onTickUpdate)>
	@Override public void <#if data.tickRandomly && (data.blockBase?has_content && data.blockBase == "Stairs")>randomTick<#else>tick</#if>
			(BlockState blockstate, ServerLevel world, BlockPos pos, Random random) {
		super.<#if data.tickRandomly && (data.blockBase?has_content && data.blockBase == "Stairs")>randomTick<#else>tick</#if>(blockstate, world, pos, random);
		int x = pos.getX();
		int y = pos.getY();
		int z = pos.getZ();

		<@procedureOBJToCode data.onTickUpdate/>

		<#if !data.tickRandomly>
		world.getBlockTicks().scheduleTick(new BlockPos(x, y, z), this, ${data.tickRate});
		</#if>
	}
	</#if>

	<#if hasProcedure(data.onRandomUpdateEvent) || data.spawnParticles>
	@OnlyIn(Dist.CLIENT) @Override
	public void animateTick(BlockState blockstate, Level world, BlockPos pos, Random random) {
		super.animateTick(blockstate, world, pos, random);
		Player entity = Minecraft.getInstance().player;
		int x = pos.getX();
		int y = pos.getY();
		int z = pos.getZ();
		<#if data.spawnParticles>
	        <@particles data.particleSpawningShape data.particleToSpawn data.particleSpawningRadious
	        data.particleAmount data.particleCondition/>
	    </#if>
		<@procedureOBJToCode data.onRandomUpdateEvent/>
	}
	</#if>

	<#if hasProcedure(data.onDestroyedByPlayer)>
	@Override
	public boolean removedByPlayer(BlockState blockstate, Level world, BlockPos pos, Player entity, boolean willHarvest, FluidState fluid) {
		boolean retval = super.removedByPlayer(blockstate, world, pos, entity, willHarvest, fluid);
		int x = pos.getX();
		int y = pos.getY();
		int z = pos.getZ();
		<@procedureOBJToCode data.onDestroyedByPlayer/>
		return retval;
	}
	</#if>

	<#if hasProcedure(data.onDestroyedByExplosion)>
	@Override public void wasExploded(Level world, BlockPos pos, Explosion e) {
		super.wasExploded(world, pos, e);
		int x = pos.getX();
		int y = pos.getY();
		int z = pos.getZ();
		<@procedureOBJToCode data.onDestroyedByExplosion/>
	}
	</#if>

	<#if hasProcedure(data.onStartToDestroy)>
	@Override public void attack(BlockState blockstate, Level world, BlockPos pos, Player entity) {
		super.attack(blockstate, world, pos, entity);
		int x = pos.getX();
		int y = pos.getY();
		int z = pos.getZ();
		<@procedureOBJToCode data.onStartToDestroy/>
	}
	</#if>

	<#if hasProcedure(data.onEntityCollides)>
	@Override public void entityInside(BlockState blockstate, Level world, BlockPos pos, Entity entity) {
		super.entityInside(blockstate, world, pos, entity);
		int x = pos.getX();
		int y = pos.getY();
		int z = pos.getZ();
		<@procedureOBJToCode data.onEntityCollides/>
	}
	</#if>

	<#if hasProcedure(data.onEntityWalksOn)>
	@Override public void stepOn(Level world, BlockPos pos, BlockState blockstate, Entity entity) {
		super.stepOn(world, pos, blockstate, entity);
		int x = pos.getX();
		int y = pos.getY();
		int z = pos.getZ();
		<@procedureOBJToCode data.onEntityWalksOn/>
	}
	</#if>

	<#if hasProcedure(data.onBlockPlayedBy)>
	@Override
	public void setPlacedBy(Level world, BlockPos pos, BlockState blockstate, LivingEntity entity, ItemStack itemstack) {
		super.setPlacedBy(world, pos, blockstate, entity, itemstack);
		int x = pos.getX();
		int y = pos.getY();
		int z = pos.getZ();
		<@procedureOBJToCode data.onBlockPlayedBy/>
	}
	</#if>

	<#if hasProcedure(data.onRightClicked) || data.shouldOpenGUIOnRightClick()>
	@Override
	public InteractionResult use(BlockState blockstate, Level world, BlockPos pos, Player entity, InteractionHand hand, BlockHitResult hit) {
		super.use(blockstate, world, pos, entity, hand, hit);

		int x = pos.getX();
		int y = pos.getY();
		int z = pos.getZ();

		<#if data.shouldOpenGUIOnRightClick()>
			if(entity instanceof ServerPlayer) {
				NetworkHooks.openGui((ServerPlayer) entity, new MenuProvider() {
					@Override public Component getDisplayName() {
						return new TextComponent("${data.name}");
					}
					@Override public AbstractContainerMenu createMenu(int id, Inventory inventory, Player player) {
						return new ${data.guiBoundTo}Menu(id, inventory, new FriendlyByteBuf(Unpooled.buffer()).writeBlockPos(new BlockPos(x, y, z)));
					}
				}, new BlockPos(x, y, z));
			}
		</#if>

		<#if hasProcedure(data.onRightClicked)>
			double hitX = hit.getLocation().x;
			double hitY = hit.getLocation().y;
			double hitZ = hit.getLocation().z;
			Direction direction = hit.getDirection();
			<#if hasReturnValue(data.onRightClicked)>
			InteractionResult result = <@procedureOBJToInteractionResultCode data.onRightClicked/>;
			<#else>
			<@procedureOBJToCode data.onRightClicked/>
			</#if>
		</#if>

		<#if data.shouldOpenGUIOnRightClick() || !hasReturnValue(data.onRightClicked)>
		return InteractionResult.SUCCESS;
		<#else>
		return result;
		</#if>
	}
	</#if>

	<#if data.hasInventory>
		@Override public MenuProvider getMenuProvider(BlockState state, Level worldIn, BlockPos pos) {
			BlockEntity tileEntity = worldIn.getBlockEntity(pos);
			return tileEntity instanceof MenuProvider ? (MenuProvider) tileEntity : null;
		}

		@Override public BlockEntity newBlockEntity(BlockPos pos, BlockState state) {
		    return new ${name}BlockEntity(pos, state);
		}

	    @Override
		public boolean triggerEvent(BlockState state, Level world, BlockPos pos, int eventID, int eventParam) {
			super.triggerEvent(state, world, pos, eventID, eventParam);
			BlockEntity blockEntity = world.getBlockEntity(pos);
			return blockEntity == null ? false : blockEntity.triggerEvent(eventID, eventParam);
		}

	    <#if data.inventoryDropWhenDestroyed>
		@Override public void onRemove(BlockState state, Level world, BlockPos pos, BlockState newState, boolean isMoving) {
			if (state.getBlock() != newState.getBlock()) {
				BlockEntity blockEntity = world.getBlockEntity(pos);
				if (blockEntity instanceof ${name}BlockEntity) {
					Containers.dropContents(world, pos, (${name}BlockEntity) blockEntity);
					world.updateNeighbourForOutputSignal(pos, this);
				}

				super.onRemove(state, world, pos, newState, isMoving);
			}
		}
	    </#if>

	    <#if data.inventoryComparatorPower>
	    @Override public boolean hasAnalogOutputSignal(BlockState state) {
			return true;
		}

	    @Override public int getAnalogOutputSignal(BlockState blockState, Level world, BlockPos pos) {
			BlockEntity tileentity = world.getBlockEntity(pos);
			if (tileentity instanceof ${name}BlockEntity)
				return AbstractContainerMenu.getRedstoneSignalFromContainer((${name}BlockEntity) tileentity);
			else
				return 0;
		}
	    </#if>
	</#if>

	<#if data.transparencyType != "SOLID">
	@OnlyIn(Dist.CLIENT) public static void registerRenderLayer() {
		<#if data.transparencyType == "CUTOUT">
		ItemBlockRenderTypes.setRenderLayer(${JavaModName}Blocks.${data.getModElement().getRegistryNameUpper()}, RenderType.cutout());
		<#elseif data.transparencyType == "CUTOUT_MIPPED">
		ItemBlockRenderTypes.setRenderLayer(${JavaModName}Blocks.${data.getModElement().getRegistryNameUpper()}, RenderType.cutoutMipped());
		<#elseif data.transparencyType == "TRANSLUCENT">
		ItemBlockRenderTypes.setRenderLayer(${JavaModName}Blocks.${data.getModElement().getRegistryNameUpper()}, RenderType.translucent());
		<#else>
		ItemBlockRenderTypes.setRenderLayer(${JavaModName}Blocks.${data.getModElement().getRegistryNameUpper()}, RenderType.solid());
		</#if>
	}
	<#elseif data.hasTransparency> <#-- for cases when user selected SOLID but checked transparency -->
	@OnlyIn(Dist.CLIENT) public static void registerRenderLayer() {
		ItemBlockRenderTypes.setRenderLayer(${JavaModName}Blocks.${data.getModElement().getRegistryNameUpper()}, RenderType.cutout());
	}
	</#if>

	<#if data.tintType != "No tint">
		@OnlyIn(Dist.CLIENT) public static void blockColorLoad(ColorHandlerEvent.Block event) {
			event.getBlockColors().register((bs, world, pos, index) -> {
					return world != null && pos != null ?
					<#if data.tintType == "Grass">
						BiomeColors.getAverageGrassColor(world, pos) : GrassColor.get(0.5D, 1.0D);
					<#elseif data.tintType == "Foliage">
						BiomeColors.getAverageFoliageColor(world, pos) : FoliageColor.getDefaultColor();
					<#elseif data.tintType == "Water">
						BiomeColors.getAverageWaterColor(world, pos) : -1;
					<#elseif data.tintType == "Sky">
						Minecraft.getInstance().level.getBiome(pos).getSkyColor() : 8562943;
					<#elseif data.tintType == "Fog">
						Minecraft.getInstance().level.getBiome(pos).getFogColor() : 12638463;
					<#else>
						Minecraft.getInstance().level.getBiome(pos).getWaterFogColor() : 329011;
					</#if>
			}, ${JavaModName}Blocks.${data.getModElement().getRegistryNameUpper()});
		}

		<#if data.isItemTinted>
		@OnlyIn(Dist.CLIENT) public static void itemColorLoad(ColorHandlerEvent.Item event) {
			event.getItemColors().register((stack, index) -> {
				<#if data.tintType == "Grass">
					return GrassColor.get(0.5D, 1.0D);
				<#elseif data.tintType == "Foliage">
					return FoliageColor.getDefaultColor();
				<#elseif data.tintType == "Water">
					return 3694022;
				<#elseif data.tintType == "Sky">
					return 8562943;
				<#elseif data.tintType == "Fog">
					return 12638463;
				<#else>
					return 329011;
				</#if>
			}, ${JavaModName}Blocks.${data.getModElement().getRegistryNameUpper()});
		}
		</#if>
	</#if>

}
<#-- @formatter:on -->
