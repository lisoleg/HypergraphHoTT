# Gudhi 接口说明

## 概述

本目录下的 Coq 代码可以通过提取 Dowker 复形参数，与 Python 的 [gudhi](https://gudhi.inria.fr/) 拓扑数据分析库进行数值验证对比。

## 验证流程

### 1. 从 Coq 提取超图参数

在 Coq 中定义超图后，提取以下参数：
- 顶点数 `num_vertices H`
- 超边列表 `enum (E H)`
- 每条超边的顶点成员 `enum e`

### 2. 在 Python/gudhi 中构造 Dowker 复形

```python
import gudhi
import numpy as np

def hypergraph_to_dowker(vertices, edges):
    """
    从超图参数构造 Dowker 复形。
    
    参数:
        vertices: 顶点列表
        edges: 超边列表，每个超边是顶点索引的集合
    
    返回:
        gudhi SimplexTree 对象
    """
    st = gudhi.SimplexTree()
    
    # 构造 Dowker 复形的单形
    # k-单形 = V' ⊆ V 使得 ∃e ∈ E, V' ⊆ e
    for edge in edges:
        # 对每条超边 e，添加 e 的所有子集作为单形
        from itertools import combinations
        for k in range(1, len(edge) + 1):
            for simplex in combinations(edge, k):
                st.insert(simplex)
    
    return st

# 示例：五顶点环超图
# V = {0, 1, 2, 3, 4}, E = {{0,1,2}, {2,3,4}, {0,4}}
vertices = [0, 1, 2, 3, 4]
edges = [{0, 1, 2}, {2, 3, 4}, {0, 4}]

st = hypergraph_to_dowker(vertices, edges)
st.compute_persistence()

# 计算同调群
homology = st.persistence_homology()
print(f"H₀ = {st.persistent_betti_numbers(0, 0)}")
print(f"H₁ = {st.persistent_betti_numbers(1, 0)}")
```

### 3. 对比验证

对比 gudhi 计算的同调群与 Coq 中珠帘类型空间的同伦群：
- **预言 P-TY-I**: π_k(𝒫ℭ(H)) ≅ H_k(D(H))
- 若 gudhi 计算的 H₁(D(H)) ≅ ℤ，则 π₁(𝒫ℭ(H)) 也应 ≅ ℤ

### 4. 批量验证

```python
# 随机生成 1000 个连通超图（|V| ≤ 20, |E| ≤ 50）
import random

def random_hypergraph(max_v=20, max_e=50):
    n = random.randint(3, max_v)
    m = random.randint(1, max_e)
    vertices = list(range(n))
    edges = []
    for _ in range(m):
        size = random.randint(2, min(5, n))
        edge = set(random.sample(vertices, size))
        edges.append(edge)
    return vertices, edges

# 批量验证 P-TY-I
results = []
for _ in range(1000):
    v, e = random_hypergraph()
    st = hypergraph_to_dowker(v, e)
    st.compute_persistence()
    results.append(st.persistent_betta_numbers(1, 0))
```

## 依赖

- Python ≥ 3.8
- gudhi ≥ 3.7: `pip install gudhi`
- numpy: `pip install numpy`

## 注意事项

1. gudhi 使用整数索引表示顶点，与 Coq 的 `finType` 对应
2. Dowker 复形在 gudhi 中通过 `SimplexTree` 表示
3. 预言 P-TY-I 的验证需要同伦群计算工具（gudhi 主要提供同调群），基本群与第一同调群的关系由 Hurewicz 定理建立
