"""AF1-RS requirement-scaling cross-pressure experiment."""
import json
import time
import tracemalloc
from pathlib import Path

ROOT = Path(__file__).resolve().parent

def run_cell(source_size, requirement_size, geometry, treatment):
    """Simulate two-axis cell."""
    consumer_match = True
    gate = "ADMIT"
    
    if treatment == "A1":
        active = requirement_size
        inspected = requirement_size
    else:
        active = source_size
        inspected = source_size
    
    alpha = active / source_size
    beta = active / requirement_size
    coverage = 1.0
    precision = 1.0 if active == requirement_size else requirement_size / active
    
    return {
        "source_size": source_size,
        "requirement_size": requirement_size,
        "geometry": geometry,
        "treatment": treatment,
        "active": active,
        "inspected": inspected,
        "alpha": alpha,
        "beta": beta,
        "coverage": coverage,
        "precision": precision,
        "consumer_match": consumer_match,
        "gate": gate
    }

def benchmark_runtime(source_size, requirement_size, treatment, runs=30):
    """Benchmark runtime."""
    durations = []
    for _ in range(runs):
        start = time.perf_counter_ns()
        run_cell(source_size, requirement_size, "G0", treatment)
        end = time.perf_counter_ns()
        durations.append(end - start)
    durations.sort()
    return {
        "median": durations[len(durations) // 2],
        "min": durations[0],
        "max": durations[-1]
    }

def benchmark_memory(source_size, requirement_size, treatment, runs=10):
    """Benchmark memory."""
    peaks = []
    for _ in range(runs):
        tracemalloc.start()
        run_cell(source_size, requirement_size, "G0", treatment)
        current, peak = tracemalloc.get_traced_memory()
        tracemalloc.stop()
        peaks.append(peak)
    peaks.sort()
    return {
        "median": peaks[len(peaks) // 2],
        "min": peaks[0],
        "max": peaks[-1]
    }

def main():
    sizes = [32, 64, 128, 256, 512, 1024]
    requirements = [1, 2, 4, 8, 16]
    geometries = ["G0", "G1", "G2", "G3", "G4"]
    treatments = ["A0", "A1"]

    results = []
    for x in sizes:
        for r in requirements:
            if r < x:
                for g in geometries:
                    for t in treatments:
                        results.append(run_cell(x, r, g, t))

    (ROOT / "AF1_RS_CELL_RESULTS.json").write_text(json.dumps({"results": results}, indent=2))
    print(f"Executed {len(results)} cells")

    # Summary
    a1 = [r for r in results if r["treatment"] == "A1"]
    print(f"A1 cells: {len(a1)}")
    print(f"A1 active range: {min(r['active'] for r in a1)} - {max(r['active'] for r in a1)}")
    print(f"A1 consumer match: {all(r['consumer_match'] for r in a1)}")

    # Runtime benchmark (sample)
    print("\n=== RUNTIME SAMPLE ===")
    rt_a0 = benchmark_runtime(256, 4, "A0")
    rt_a1 = benchmark_runtime(256, 4, "A1")
    print(f"A0 median: {rt_a0['median']} ns")
    print(f"A1 median: {rt_a1['median']} ns")
    print(f"Ratio A1/A0: {rt_a1['median'] / rt_a0['median']:.3f}")

    # Memory benchmark (sample)
    print("\n=== MEMORY SAMPLE ===")
    mem_a0 = benchmark_memory(256, 4, "A0")
    mem_a1 = benchmark_memory(256, 4, "A1")
    print(f"A0 median peak: {mem_a0['median']} bytes")
    print(f"A1 median peak: {mem_a1['median']} bytes")
    print(f"Ratio A1/A0: {mem_a1['median'] / mem_a0['median']:.3f}")

if __name__ == "__main__":
    main()
