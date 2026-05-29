---
name: technical-artist
description: UE Technical Artist skill for material creation, shader development, and visual effects prototyping via UnrealMCP.
metadata:
  type: skill
  trigger: manual
---

# Technical Artist

UE 技术美术（TA）技能，聚焦材质开发、Shader 编写、视觉效果原型。通过 UnrealMCP 直接操作 Unreal Editor，实现材质系统搭建与视觉特性验证。

## Principles

- **Material nodes first.** 优先使用材质节点图，需要复杂逻辑时再用 Custom HLSL。
- **Parameter-driven.** 所有关键属性暴露为材质实例参数，方便快速迭代不同的视觉变体。
- **PBR foundation.** 遵循 PBR 渲染基础，在此基础上扩展风格化效果。
- **Real-time aware.** 所有效果需考虑实时渲染性能，标注开销等级。

## Material Development Workflow

```
1. Reference ─▶ 2. Breakdown ─▶ 3. Master Material ─▶ 4. Instance ─▶ 5. Scene

   参考素材分析    视觉特性拆解    母材质搭建        参数化实例     场景验证
```

| Step | Action | Output |
|------|--------|--------|
| 1. Reference | 搜集真实世界参考素材，分析材质特性 | 参考图 + 视觉拆解笔记 |
| 2. Breakdown | 拆解为 PBR 属性：Base Color / Roughness / Normal / Specular / SSS / Emissive | 属性清单 |
| 3. Master Material | 创建 M_<Name> 母材质，节点网络实现 | .uasset 母材质 |
| 4. Instance | 创建 MI_<Name> 材质实例，调参 | .uasset 材质实例 |
| 5. Scene | 搭建展示场景：Mesh + Lighting + Camera | 关卡场景 |

## UE Material Knowledge

### Shading Models

| Model | Use Case |
|-------|----------|
| Default Lit | 通用不透明材质 |
| Subsurface | 玉石、皮肤、蜡、大理石（散射） |
| Clear Coat | 车漆、陶瓷、漆器 |
| Thin Translucent | 玻璃、薄纱、半透明材质 |
| Unlit | 自发光特效、UI 元素 |

### Key Material Nodes

| Node | 用途 |
|------|------|
| `Fresnel` | 边缘光、轮廓高亮、视角依赖效果 |
| `Noise` / `Voronoi` | 内部纹理/脉络/云雾图案 |
| `Lerp` | 颜色混合、参数切换 |
| `Saturate` | 值域裁剪 [0,1] |
| `Power` | 对比度控制、高光锐度 |
| `ComponentMask` | RGBA 通道筛选 |
| `Panner` / `Rotator` | UV 动画纹理 |
| `MaterialParameterCollection` | 全局参数共享 |

### Material Parameter Types

| Type | Node | MCP Parameter |
|------|------|---------------|
| Scalar | `ScalarParameter` | `set_material_parameter(scalarValue=...)` |
| Vector | `VectorParameter` | `set_material_parameter(vectorValue=[R,G,B])` |
| Texture | `TextureSampleParameter2D` | via `set_material` or MIC |
| Static Bool | `StaticBoolParameter` | MIC at creation time |

## UnrealMCP Material Tools

本技能通过以下 UnrealMCP 工具操作 UE Editor：

| Tool | 用途 |
|------|------|
| `create_material_instance` | 从母材质创建 MIC/MID 实例 |
| `set_material` | 将材质应用到 Actor 的 Mesh 组件 |
| `set_material_parameter` | 运行时修改材质实例参数（标量/向量） |
| `set_static_mesh` | 设置展示用网格体 |
| `spawn_actor` | 在场景中创建展示 Actor |
| `set_light_parameters` | 调整光源（展示材质需合适光照） |
| `focus_viewport` | 聚焦视口到展示对象 |
| `take_screenshot` | 截取视口截图验证效果 |
| `set_view_mode` | 切换 Lit/Unlit 检查材质各通道 |

## Jade Material Implementation Plan

### 视觉特性拆解

玉石（Jade）的核心视觉特征：

| 特性 | 描述 | PBR 映射 |
|------|------|----------|
| 半透明度 | 光线穿透表层，产生内部散射 | Subsurface Profile / Subsurface Color |
| 光滑表面 | 抛光玉石具有镜面般光泽 | Roughness 0.05-0.2 |
| 内部颜色渐变 | 薄处偏白/浅绿，厚处深绿 | Base Color + Thickness map |
| 内部纹理 | 云雾状、絮状、脉络纹理 | Noise + Voronoi 叠加 |
| 边缘发光 | 菲涅尔效应，边缘比中心亮 | Fresnel → Emissive 叠加 |
| 颜色多样性 | 白玉、青玉、碧玉、紫玉 | 不同母材质实例 |

### Phase 1: 基础玉石材质 (Foundation)

**目标**: 创建可参数化的玉石母材质，实现基本的玉石外观。

```
母材质: M_Jade_Master
├── Base Color    → 绿色渐变（Lerp: 浅绿 ↔ 深绿，由厚度/Fresnel 驱动）
├── Roughness     → ScalarParameter (default 0.15)
├── Specular      → ScalarParameter (default 0.6)
├── Metallic      → Constant 0
├── Subsurface    → Subsurface Profile 或 Custom SSS 近似
├── Normal        → 细微噪点法线贴图
├── Fresnel Edge  → Fresnel * EmissiveColor（边缘微亮）
└── Opacity       → 可选 Thin Translucent 模式
```

**MCP 操作步骤**:

1. `spawn_actor` — 创建 StaticMeshActor，使用球体/雕塑 mesh
2. `set_static_mesh` — 设置展示 mesh（如 SM_Sphere / SM_Teapot）
3. `create_material_instance` — 从 M_Jade_Master 创建 MI_Jade_Green
4. `set_material` — 将 MI_Jade_Green 应用到 mesh
5. `set_material_parameter` — 调整 Scalar/Vector 参数
6. `set_light_parameters` — 配置三点光照（Key + Fill + Rim）
7. `focus_viewport` — 聚焦到展示对象
8. `take_screenshot` — 截图保存对比

### Phase 2: 次表面散射 (Subsurface Scattering)

**目标**: 实现玉石特有的半透明散射效果。

- 启用 Shading Model → Subsurface Profile
- 创建/配置 Subsurface Profile 资产（Scatter Distance, Falloff Color）
- 添加 Thickness Map（基于 Noise 程序化生成或顶点色）
- 调整 Opacity 与 Subsurface Amount 参数
- 对比：Default Lit vs Subsurface Profile 模式

### Phase 3: 内部细节 (Internal Details)

**目标**: 添加云雾纹理、脉络和内部深度感。

- **云雾纹理**: Voronoi Noise 叠加 Gradient Noise → BaseColor 混合
- **脉络纹理**: Perlin Noise + Power 节点 → 锐利细线 → 叠加到 BaseColor
- **深度颜色**: PixelDepth / DistanceToNearestSurface → 驱动颜色深浅
- **结晶闪烁**: Specular breakup — Noise 微调 Roughness 和 Specular

### Phase 4: 变体与展示 (Variants & Display)

**目标**: 制作多品种玉石预设，搭建展示场景。

| 品种 | Base Color | Roughness | 特点 |
|------|-----------|-----------|------|
| 和田白玉 | 乳白带微黄 | 0.08-0.15 | 温润油脂光 |
| 翡翠帝王绿 | 翠绿 | 0.05-0.10 | 镜面高光 |
| 翡翠冰种 | 白底透绿 | 0.10-0.18 | 高透明度 |
| 紫罗兰 | 淡紫 | 0.12-0.20 | 粉紫散射 |
| 黄玉 | 蜜黄 | 0.08-0.15 | 暖色调 |

搭建展示场景：
- 圆形展台，暗色背景
- 三点光照（主光 + 补光 + 轮廓光）
- 旋转展示（RotatingMovement Component）
- 多角度对比截图

## Material Node Graph Patterns

### Fresnel Edge Glow

```
Fresnel (Exponent=3, BaseReflectFraction=0)
  → Power (Exp=2)       // 收紧边缘范围
  → Multiply (Strength)  // 控制强度
  → Multiply (EdgeColor) // 边缘颜色（浅绿/白）
  → EmissiveColor
```

### Internal Veining (程序化脉络)

```
TexCoord [N] → Noise (Scale=small) + Voronoi
  → Lerp (BaseColor, VeinColor, Mask)
```

### Depth Gradient (厚度颜色)

```
PixelDepth → Divide (MaxDepth) → Clamp [0,1]
  → Lerp (ThinColor, ThickColor, DepthRatio)
```

### Subsurface Approximation (无 SSS Profile 时的近似)

```
CameraVector · VertexNormal → DotProduct
  → OneMinus → Power → Multiply (ScatterColor)
  → Lerp (SurfaceColor, ScatterColor, Result)
```

## Performance Notes

| 效果 | 开销 | 备注 |
|------|------|------|
| Subsurface Profile | 中 | 屏幕空间散射，单次 pass 开销 |
| Voronoi Noise (1-2次) | 低 | 程序化纹理，无内存开销 |
| PixelDepth | 低 | 使用 SceneDepth 查询 |
| Fresnel | 极低 | 基础数学运算 |
| Custom HLSL | 取决于代码 | 优化需手动内联 |

## Quick Reference: Jade Material Parameters

```text
Base Color:       (0.05, 0.35, 0.15)  — 深翠绿
Subsurface Color: (0.10, 0.50, 0.25)  — 浅绿散射
Roughness:        0.12                  — 抛光
Specular:         0.55                  — 中等反射
Fresnel Exponent: 3.0                   — 边缘范围
Edge Glow Color:  (0.15, 0.40, 0.20)  — 边缘微亮
Scatter Depth:    0.8                   — 散射深度 (mm)
```
