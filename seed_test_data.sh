#!/bin/bash
# 博客CMS测试数据脚本
# 使用前确保 docker compose up -d 已启动且后端正常运行

BASE_URL="http://localhost:8000/api"

echo "========== 1. 注册用户 =========="

# 注册用户1: admin01
echo ">>> 注册 admin01"
curl -s -X POST "$BASE_URL/users/register/" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin01",
    "email": "admin01@test.com",
    "password": "Test@12345",
    "password2": "Test@12345",
    "nickname": "管理员小王"
  }' | python3 -m json.tool

# 注册用户2: author01
echo ">>> 注册 author01"
curl -s -X POST "$BASE_URL/users/register/" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "author01",
    "email": "author01@test.com",
    "password": "Test@12345",
    "password2": "Test@12345",
    "nickname": "作者小李"
  }' | python3 -m json.tool

# 注册用户3: reader01
echo ">>> 注册 reader01"
curl -s -X POST "$BASE_URL/users/register/" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "reader01",
    "email": "reader01@test.com",
    "password": "Test@12345",
    "password2": "Test@12345",
    "nickname": "读者小张"
  }' | python3 -m json.tool

echo ""
echo "========== 2. 登录获取Token =========="

# 登录 admin01
echo ">>> 登录 admin01"
ADMIN_TOKEN=$(curl -s -X POST "$BASE_URL/users/login/" \
  -H "Content-Type: application/json" \
  -d '{"username": "admin01", "password": "Test@12345"}' | python3 -c "import sys,json; print(json.load(sys.stdin)['access'])")
echo "admin01 token: ${ADMIN_TOKEN:0:20}..."

# 登录 author01
echo ">>> 登录 author01"
AUTHOR_TOKEN=$(curl -s -X POST "$BASE_URL/users/login/" \
  -H "Content-Type: application/json" \
  -d '{"username": "author01", "password": "Test@12345"}' | python3 -c "import sys,json; print(json.load(sys.stdin)['access'])")
echo "author01 token: ${AUTHOR_TOKEN:0:20}..."

# 登录 reader01
echo ">>> 登录 reader01"
READER_TOKEN=$(curl -s -X POST "$BASE_URL/users/login/" \
  -H "Content-Type: application/json" \
  -d '{"username": "reader01", "password": "Test@12345"}' | python3 -c "import sys,json; print(json.load(sys.stdin)['access'])")
echo "reader01 token: ${READER_TOKEN:0:20}..."

echo ""
echo "========== 3. 创建分类（通过Django管理命令） =========="

# 分类和标签没有创建接口（ReadOnlyModelViewSet），用 Django shell 创建
docker exec blog_backend python manage.py shell -c "
from articles.models import Category, Tag

# 创建分类
categories = [
    ('前端开发', 'frontend', '前端技术相关文章'),
    ('后端开发', 'backend', '后端技术相关文章'),
    ('数据库', 'database', '数据库技术相关'),
    ('DevOps', 'devops', '运维部署相关'),
    ('人工智能', 'ai', 'AI和机器学习'),
]
for name, slug, desc in categories:
    Category.objects.get_or_create(name=name, defaults={'slug': slug, 'description': desc})

# 创建标签
tags = [
    ('Python', 'python'),
    ('JavaScript', 'javascript'),
    ('Docker', 'docker'),
    ('Vue', 'vue'),
    ('React', 'react'),
    ('Django', 'django'),
    ('PostgreSQL', 'postgresql'),
    ('Redis', 'redis'),
    ('TypeScript', 'typescript'),
    ('CSS', 'css'),
]
for name, slug in tags:
    Tag.objects.get_or_create(name=name, defaults={'slug': slug})

print('分类和标签创建完成')
"

echo ""
echo "========== 4. 创建文章 =========="

# 文章1: admin01 发布 - 前端分类 + JavaScript/Vue标签
echo ">>> 创建文章1 (admin01)"
curl -s -X POST "$BASE_URL/articles/" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -d '{
    "title": "Vue 3 组合式API完全指南",
    "content": "## 什么是组合式API\n\nVue 3 引入了组合式API（Composition API），它是一种新的编写组件逻辑的方式。\n\n### 基本用法\n\n```javascript\nimport { ref, computed } from \"vue\"\n\nexport default {\n  setup() {\n    const count = ref(0)\n    const doubled = computed(() => count.value * 2)\n    \n    function increment() {\n      count.value++\n    }\n    \n    return { count, doubled, increment }\n  }\n}\n```\n\n### 响应式原理\n\nVue 3 使用 Proxy 替代了 Vue 2 的 Object.defineProperty，性能更好。\n\n> 组合式API让代码组织更灵活，逻辑复用更方便。\n\n- 更好的TypeScript支持\n- 更灵活的代码组织\n- 更容易的逻辑复用",
    "status": "published",
    "category": 1,
    "tags": [2, 4]
  }' | python3 -m json.tool

# 文章2: admin01 发布 - 后端分类 + Python/Django标签
echo ">>> 创建文章2 (admin01)"
curl -s -X POST "$BASE_URL/articles/" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -d '{
    "title": "Django REST Framework 最佳实践",
    "content": "## DRF 项目结构\n\n一个好的DRF项目应该有清晰的目录结构。\n\n### Serializer 设计\n\n```python\nclass ArticleSerializer(serializers.ModelSerializer):\n    author = UserSerializer(read_only=True)\n    \n    class Meta:\n        model = Article\n        fields = [\"id\", \"title\", \"content\", \"author\"]\n```\n\n### ViewSet 使用\n\n```python\nclass ArticleViewSet(viewsets.ModelViewSet):\n    queryset = Article.objects.all()\n    serializer_class = ArticleSerializer\n    permission_classes = [IsAuthenticatedOrReadOnly]\n```\n\n### 分页配置\n\n在 settings.py 中配置全局分页：\n\n```python\nREST_FRAMEWORK = {\n    \"DEFAULT_PAGINATION_CLASS\": \"rest_framework.pagination.PageNumberPagination\",\n    \"PAGE_SIZE\": 10,\n}\n```",
    "status": "published",
    "category": 2,
    "tags": [1, 6]
  }' | python3 -m json.tool

# 文章3: author01 发布 - 数据库分类 + PostgreSQL标签
echo ">>> 创建文章3 (author01)"
curl -s -X POST "$BASE_URL/articles/" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $AUTHOR_TOKEN" \
  -d '{
    "title": "PostgreSQL 性能优化实战",
    "content": "## 索引优化\n\nPostgreSQL 提供了多种索引类型。\n\n### B-Tree 索引\n\n最常用的索引类型，适合等值查询和范围查询。\n\n```sql\nCREATE INDEX idx_articles_title ON articles(title);\nCREATE INDEX idx_articles_created ON articles(created_at DESC);\n```\n\n### 查询计划分析\n\n使用 EXPLAIN ANALYZE 分析查询性能：\n\n```sql\nEXPLAIN ANALYZE\nSELECT * FROM articles\nWHERE category_id = 1\nAND created_at > \"2024-01-01\"\nORDER BY created_at DESC\nLIMIT 10;\n```\n\n### 连接池配置\n\n推荐使用 PgBouncer 做连接池管理。",
    "status": "published",
    "category": 3,
    "tags": [1, 7]
  }' | python3 -m json.tool

# 文章4: author01 发布 - DevOps分类 + Docker标签
echo ">>> 创建文章4 (author01)"
curl -s -X POST "$BASE_URL/articles/" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $AUTHOR_TOKEN" \
  -d '{
    "title": "Docker Compose 多服务编排详解",
    "content": "## Docker Compose 基础\n\n### docker-compose.yml 结构\n\n```yaml\nversion: \"3.8\"\nservices:\n  web:\n    build: ./frontend\n    ports:\n      - \"3000:3000\"\n  api:\n    build: ./backend\n    ports:\n      - \"8000:8000\"\n    depends_on:\n      - db\n  db:\n    image: postgres:15\n    environment:\n      POSTGRES_DB: mydb\n```\n\n### 网络配置\n\nCompose 会自动创建一个默认网络，所有服务都可以通过服务名互相访问。\n\n### 数据持久化\n\n使用 volumes 持久化数据：\n\n```yaml\nvolumes:\n  postgres_data:\n```",
    "status": "published",
    "category": 4,
    "tags": [3]
  }' | python3 -m json.tool

# 文章5: admin01 发布 - 前端分类 + React/TypeScript标签
echo ">>> 创建文章5 (admin01)"
curl -s -X POST "$BASE_URL/articles/" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -d '{
    "title": "React Hooks 深入理解",
    "content": "## useState 和 useEffect\n\nReact Hooks 是 React 16.8 引入的新特性。\n\n### useState\n\n```typescript\nconst [count, setCount] = useState<number>(0)\n```\n\n### useEffect\n\n```typescript\nuseEffect(() => {\n  document.title = `点击了 ${count} 次`\n  return () => {\n    // cleanup\n  }\n}, [count])\n```\n\n### 自定义Hook\n\n```typescript\nfunction useLocalStorage<T>(key: string, initialValue: T) {\n  const [value, setValue] = useState<T>(() => {\n    const stored = localStorage.getItem(key)\n    return stored ? JSON.parse(stored) : initialValue\n  })\n  \n  useEffect(() => {\n    localStorage.setItem(key, JSON.stringify(value))\n  }, [key, value])\n  \n  return [value, setValue] as const\n}\n```",
    "status": "published",
    "category": 1,
    "tags": [5, 9]
  }' | python3 -m json.tool


# 文章6-12: 多创建几篇用于测试分页（每页10条）
for i in $(seq 6 15); do
  echo ">>> 创建文章$i (填充分页数据)"
  curl -s -X POST "$BASE_URL/articles/" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -d "{
      \"title\": \"技术分享第${i}篇：编程技巧与心得\",
      \"content\": \"## 第${i}篇技术分享\n\n这是一篇用于测试分页功能的文章。\n\n### 要点\n\n- 要点一：保持代码简洁\n- 要点二：写好注释\n- 要点三：做好测试\n\n\`\`\`python\ndef hello():\n    print('Hello World')\n\`\`\`\",
      \"status\": \"published\",
      \"category\": $(( (i % 5) + 1 )),
      \"tags\": [$(( (i % 3) + 1 ))]
    }" > /dev/null
done
echo "文章6-15创建完成（共15篇，用于测试分页）"

echo ""
echo "========== 5. 创建评论 =========="

# reader01 对文章1评论
echo ">>> reader01 评论文章1"
COMMENT1=$(curl -s -X POST "$BASE_URL/comments/" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $READER_TOKEN" \
  -d '{
    "article": 1,
    "content": "写得很好！Vue 3 的组合式API确实比选项式API灵活很多，特别是在大型项目中。"
  }')
echo "$COMMENT1" | python3 -m json.tool
COMMENT1_ID=$(echo "$COMMENT1" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])" 2>/dev/null)

# admin01 回复 reader01 的评论
echo ">>> admin01 回复评论"
curl -s -X POST "$BASE_URL/comments/" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -d "{
    \"article\": 1,
    \"content\": \"谢谢支持！后续会写更多Vue 3相关的文章。\",
    \"parent\": $COMMENT1_ID
  }" | python3 -m json.tool

# author01 对文章1评论
echo ">>> author01 评论文章1"
curl -s -X POST "$BASE_URL/comments/" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $AUTHOR_TOKEN" \
  -d '{
    "article": 1,
    "content": "组合式API配合TypeScript用起来体验很好，强烈推荐。"
  }' | python3 -m json.tool

# reader01 对文章2评论
echo ">>> reader01 评论文章2"
curl -s -X POST "$BASE_URL/comments/" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $READER_TOKEN" \
  -d '{
    "article": 2,
    "content": "DRF的ViewSet确实很方便，但有时候自定义逻辑多了还是用APIView更灵活。"
  }' | python3 -m json.tool

# reader01 对文章3评论（用于测试权限：reader01不是作者，不应该能删admin01/author01的评论）
echo ">>> reader01 评论文章3"
curl -s -X POST "$BASE_URL/comments/" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $READER_TOKEN" \
  -d '{
    "article": 3,
    "content": "PostgreSQL的JSONB类型也很强大，可以加一篇讲讲。"
  }' | python3 -m json.tool

echo ""
echo "========== 6. 测试验证 =========="

echo ""
echo ">>> 测试分类筛选（分类1=前端开发）"
curl -s "$BASE_URL/articles/?category=1" | python3 -c "
import sys, json
data = json.load(sys.stdin)
results = data.get('results', data)
print(f'分类1的文章数: {len(results)}')
for a in results:
    print(f'  - [{a[\"id\"]}] {a[\"title\"]} (分类: {a.get(\"category\",{}).get(\"name\",\"无\")})')
"

echo ""
echo ">>> 测试标签筛选（标签1=Python）"
curl -s "$BASE_URL/articles/?tag=1" | python3 -c "
import sys, json
data = json.load(sys.stdin)
results = data.get('results', data)
print(f'标签Python的文章数: {len(results)}')
for a in results:
    print(f'  - [{a[\"id\"]}] {a[\"title\"]}')
"

echo ""
echo ">>> 测试分类+标签同时筛选（分类2=后端 + 标签1=Python）"
curl -s "$BASE_URL/articles/?category=2&tag=1" | python3 -c "
import sys, json
data = json.load(sys.stdin)
results = data.get('results', data)
print(f'后端+Python的文章数: {len(results)}')
for a in results:
    tags = [t['name'] for t in a.get('tags', [])]
    print(f'  - [{a[\"id\"]}] {a[\"title\"]} (分类: {a.get(\"category\",{}).get(\"name\",\"无\")}, 标签: {tags})')
"

echo ""
echo ">>> 测试分页（应该只返回10条，有next链接）"
curl -s "$BASE_URL/articles/" | python3 -c "
import sys, json
data = json.load(sys.stdin)
if 'results' in data:
    print(f'总数: {data.get(\"count\", \"未知\")}')
    print(f'当前页文章数: {len(data[\"results\"])}')
    print(f'下一页: {data.get(\"next\", \"无\")}')
else:
    print(f'未分页，返回了 {len(data)} 篇文章（应该分页！）')
"

echo ""
echo ">>> 测试评论删除权限（reader01尝试删除admin01的回复评论，应该返回403）"
curl -s -o /dev/null -w "HTTP状态码: %{http_code}" -X DELETE "$BASE_URL/comments/2/" \
  -H "Authorization: Bearer $READER_TOKEN"
echo ""

echo ""
echo "========== 完成 =========="
echo ""
echo "测试账号："
echo "  admin01  / Test@12345  (管理员小王)"
echo "  author01 / Test@12345  (作者小李)"
echo "  reader01 / Test@12345  (读者小张)"
echo ""
echo "访问 http://localhost:5173 开始测试"
echo "共创建: 3个用户, 5个分类, 10个标签, 15篇文章, 5条评论"
