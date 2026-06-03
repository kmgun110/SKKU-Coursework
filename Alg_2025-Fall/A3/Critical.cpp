#include <iostream>
#include <vector>
#include <queue>
#include <fstream>

using namespace std;

int main(int argc, char* argv[]) {
    ios::sync_with_stdio(false);
    cin.tie(NULL);

    istream* in = &cin;
    ostream* out = &cout;
    ifstream fin;
    ofstream fout;

    if (argc == 3) {
        fin.open(argv[1]);
        fout.open(argv[2]);
        in = &fin;
        out = &fout;
    }

    int N, M;
    if (!(*in >> N >> M)) {
        return 0;
    }

    vector<int> timeCost(N + 1);
    for (int i = 1; i <= N; i++) {
        (*in) >> timeCost[i];
    }

    vector< vector<int> > adj(N + 1);
    vector<int> indeg(N + 1, 0);

    for (int i = 0; i < M; i++) {
        int a, b;
        (*in) >> a >> b;   // b depends on a: a -> b
        adj[a].push_back(b);
        indeg[b]++;
    }

    queue<int> q;
    vector<long long> dp(N + 1, 0);

    for (int i = 1; i <= N; i++) {
        if (indeg[i] == 0) {
            q.push(i);
            dp[i] = timeCost[i];
        }
    }

    int visitedCount = 0;

    while (!q.empty()) {
        int u = q.front();
        q.pop();
        visitedCount++;

        for (size_t i = 0; i < adj[u].size(); i++) {
            int v = adj[u][i];
            if (dp[v] < dp[u] + timeCost[v]) {
                dp[v] = dp[u] + timeCost[v];
            }
            indeg[v]--;
            if (indeg[v] == 0) {
                q.push(v);
            }
        }
    }

    if (visitedCount != N) {
        (*out) << -1 << "\n";
        return 0;
    }

    long long answer = 0;
    for (int i = 1; i <= N; i++) {
        if (answer < dp[i]) answer = dp[i];
    }

    (*out) << answer << "\n";

    return 0;
}
