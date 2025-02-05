let currentPage = 1;
const pageSize = 5;

function resultsToHtml(results) {
    if (results.length > 0) {
        return results
            .map(
                (pkg) =>
                    `<li class="cursor-pointer [&:not(:last-child)]:border-b border-zinc-500/50 p-4 hover:bg-black/5 dark:hover:bg-white/5" data-package="${pkg.name}">
            <p class="flex justify-between"><b>${pkg.name}</b> <span class="text-sm text-zinc-500">${pkg.version}</span></p>
            <p class="mt-4 text-sm line-clamp-1">${pkg.description}</p>
        </li>`
            )
            .join('');
    } else {
        return '<p class="text-xl font-bold text-zinc-600 dark:text-zinc-400 h-full flex items-center justify-center">No packages found</p>';
    }
}

function showSpinner() {
    const resultsContainer = document.getElementById('search-results');
    resultsContainer.innerHTML = `<div class="h-full">
    <div role="status" class="flex items-center justify-center h-full">
        <svg aria-hidden="true" class="inline w-8 md:w-16 h-8 md:h-16 text-gray-200 animate-spin dark:text-gray-600 fill-amber-500" viewBox="0 0 100 101" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M100 50.5908C100 78.2051 77.6142 100.591 50 100.591C22.3858 100.591 0 78.2051 0 50.5908C0 22.9766 22.3858 0.59082 50 0.59082C77.6142 0.59082 100 22.9766 100 50.5908ZM9.08144 50.5908C9.08144 73.1895 27.4013 91.5094 50 91.5094C72.5987 91.5094 90.9186 73.1895 90.9186 50.5908C90.9186 27.9921 72.5987 9.67226 50 9.67226C27.4013 9.67226 9.08144 27.9921 9.08144 50.5908Z" fill="currentColor"/>
            <path d="M93.9676 39.0409C96.393 38.4038 97.8624 35.9116 97.0079 33.5539C95.2932 28.8227 92.871 24.3692 89.8167 20.348C85.8452 15.1192 80.8826 10.7238 75.2124 7.41289C69.5422 4.10194 63.2754 1.94025 56.7698 1.05124C51.7666 0.367541 46.6976 0.446843 41.7345 1.27873C39.2613 1.69328 37.813 4.19778 38.4501 6.62326C39.0873 9.04874 41.5694 10.4717 44.0505 10.1071C47.8511 9.54855 51.7191 9.52689 55.5402 10.0491C60.8642 10.7766 65.9928 12.5457 70.6331 15.2552C75.2735 17.9648 79.3347 21.5619 82.5849 25.841C84.9175 28.9121 86.7997 32.2913 88.1811 35.8758C89.083 38.2158 91.5421 39.6781 93.9676 39.0409Z" fill="currentFill"/>
        </svg>
        <span class="sr-only">Loading...</span>
    </div>
</div>`;
}

function clearSearchResults() {
    const resultsContainer = document.getElementById('search-results');
    resultsContainer.innerHTML = '';
}

async function updateSearchResults(query) {
    try {
        showSpinner();
        const { results, total } = await searchNpmPackages(query, currentPage, pageSize);
        const resultsContainer = document.getElementById('search-results');
        clearSearchResults();
        resultsContainer.innerHTML = resultsToHtml(results);
        updatePaginationControls(total);
    } catch (error) {
        console.error('Error fetching search results:', error);
    }
}

function updatePaginationControls(total) {
    const paginationContainer = document.getElementById('pagination-controls');
    const totalPages = Math.ceil(total / pageSize);

    if (totalPages > 0) {
        paginationContainer.innerHTML = `
        ${currentPage > 1 ? `<button class="font-bold" id="prev-page">❮</button>` : '&nbsp;&nbsp;'}
        <span>Page ${currentPage} of ${totalPages}</span>
        ${currentPage < totalPages ? `<button class="font-bold" id="next-page">❯</button>` : '&nbsp;&nbsp;'}
      `;
    } else {
        paginationContainer.innerHTML = '';
    }

    document.getElementById('prev-page')?.addEventListener('click', () => {
        currentPage--;
        const query = document.getElementById('search-query').value;
        updateSearchResults(query);
    });

    document.getElementById('next-page')?.addEventListener('click', () => {
        currentPage++;
        const query = document.getElementById('search-query').value;
        updateSearchResults(query);
    });
}

function hidePaginationControls() {
    const paginationContainer = document.getElementById('pagination-controls');
    paginationContainer.innerHTML = '';
    currentPage = 1;
}

async function searchNpmPackages(query, page = 1) {
    const from = (page - 1) * pageSize;
    const response = await fetch(
        `https://registry.npmjs.org/-/v1/search?text=${encodeURIComponent(query)}&size=${pageSize}&from=${from}`
    );

    if (!response.ok) throw new Error('Failed to fetch npm packages');

    const data = await response.json();
    updatePaginationControls(data.total);
    return {
        results: data.objects.map((pkg) => ({
            name: pkg.package.name,
            description: pkg.package.description,
            version: pkg.package.version,
        })),
        total: data.total,
    };
}

async function loadNpmPackage(packageName) {
    const moduleUrl = `https://cdn.skypack.dev/${packageName}?dts`;
    console.log(`Loading package: ${moduleUrl}`);
    try {
        const module = await fetch(moduleUrl);
        console.log('Loaded ' + packageName);
        return module;
    } catch (error) {
        console.error(`Failed to load package: ${packageName}`, error);
        throw error;
    }
}

export default {
    mounted() {
        const searchInput = document.getElementById('search-query');
        const resultsContainer = document.getElementById('search-results');
        let searchTimeout;

        searchInput.addEventListener('input', async (event) => {
            clearTimeout(searchTimeout);
            const query = event.target.value;
            if (query.length < 3) {
                resultsContainer.innerHTML = '';
                hidePaginationControls();
                return;
            }
            searchTimeout = setTimeout(async () => {
                try {
                    showSpinner();
                    const { results } = await searchNpmPackages(query);
                    clearSearchResults();
                    resultsContainer.innerHTML = resultsToHtml(results);
                } catch (error) {
                    console.error('Error searching packages:', error);
                }
            }, 1000);
        });

        resultsContainer.addEventListener('click', async (event) => {
            const packageName = event.target.getAttribute('data-package');
            if (!packageName) return;

            try {
                const module = await loadTypesForPackage(packageName);
                console.log('Loaded module:', module);
            } catch (error) {
                alert(`Failed to load package: ${packageName}`);
            }
        });
    },
};

async function loadTypesForPackage(packageName) {
    return;
    // const baseUrl = `https://cdn.jsdelivr.net/npm/${packageName}`;
    // const pkg = await fetch(`${baseUrl}/package.json`);

    // const aggregatedTypes = await fetchAndResolveTypes(packageName, baseUrl);

    // console.log(`Successfully loaded types for ${packageName}`);
}

async function fetchAndResolveTypes(packageName, baseUrl, entryPoint = 'index.d.ts', resolved = new Set()) {
    const entryUrl = `${baseUrl}/${entryPoint}`;
    if (resolved.has(entryUrl)) return '';

    try {
        const response = await fetch(entryUrl);
        if (!response.ok) {
            const res = await fetch();
            throw new Error(`Failed to fetch: ${entryUrl}`);
        }

        const content = await response.text();
        resolved.add(entryUrl);

        const dependencies = extractDependencies(content);

        const dependencyPromises = dependencies.map((dep) => {
            const resolvedPath = resolveDependencyPath(baseUrl, dep);
            return fetchAndResolveTypes(packageName, baseUrl, resolvedPath, resolved);
        });

        const resolvedDependencies = await Promise.all(dependencyPromises);

        return [content, ...resolvedDependencies].join('\n');
    } catch (error) {
        console.error(`Error resolving types for ${entryPoint}:`, error);
        return '';
    }
}

function extractDependencies(content) {
    const dependencyRegex = /(?:import|export).*?from\s+['"](.*?)['"]/g;
    const matches = [...content.matchAll(dependencyRegex)];
    return matches.map((match) => match[1]).filter((dep) => dep.startsWith('.'));
}

function resolveDependencyPath(baseUrl, relativePath) {
    const url = new URL(relativePath, baseUrl);
    return url.pathname.replace(/^\/+/, '');
}
