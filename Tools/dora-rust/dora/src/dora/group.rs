extern "C" {
	fn group_type() -> i32;
	fn entitygroup_get_count(slf: i64) -> i32;
	fn entitygroup_find(slf: i64, func: i32, stack: i64) -> i64;
	fn entitygroup_new(components: i64) -> i64;
}
use crate::dora::IObject;
pub struct Group { raw: i64 }
crate::dora_object!(Group);
impl Group {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { group_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Group { raw: raw }))
			}
		})
	}
	pub fn get_count(&self) -> i32 {
		return unsafe { entitygroup_get_count(self.raw()) };
	}
	pub fn find(&self, mut func: Box<dyn FnMut(&crate::dora::Entity) -> bool>) -> Option<crate::dora::Entity> {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			let result = func(&stack.pop_cast::<crate::dora::Entity>().unwrap());
			stack.push_bool(result);
		}));
		unsafe { return crate::dora::Entity::from(entitygroup_find(self.raw(), func_id, stack_raw)); }
	}
	pub fn new(components: &Vec<&str>) -> Group {
		unsafe { return Group { raw: entitygroup_new(crate::dora::Vector::from_str(components)) }; }
	}
}