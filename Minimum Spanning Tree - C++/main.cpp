#include "minSpanningTree.h"
#include <stdexcept>

int main(int argc, char *argv[]) try {
	AdjacencyList adjacency;
	int num_nodes = ReadInputOrDie(argc, argv, &adjacency);

	std::cout << "Graph read from file: \n";
	for (auto begin = adjacency.begin(); begin != adjacency.end(); begin++) {
		for (Edge edge : begin->second) {
			auto nodes = edge.GetNodes();
			//don't print duplicates
			if (nodes[1] > nodes[0]) {
				edge.Print();
			}
		}
	}

	std::cout << "Minimum Spanning Tree:\n";
	SpanningTree mst(num_nodes, adjacency);
	if (mst.BuildMinSpanningTree()) {
		for (Edge edge : *mst.GetOptimalEdgeList()) {
			edge.Print();
		}
	}
	std::cout << "MST Weight: " << mst.GetWeight() << "\n";
}
catch (std::exception &e) {
	std::cerr << "Error: " << e.what() << "\n";
	return -1;
} 
catch (...) {
	std::cerr << "unknown error\n";
	return -1;
}